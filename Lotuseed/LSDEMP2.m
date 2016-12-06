//
//  LSDEMP2.m
//  Lotuseed
//
//  Created by beyond on 12-6-1.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDEMP2.h"
#import "LSDUtils.h"

#define EMP_VERSION            2
#define EMP_DEFAULT_ENCODING   "UTF-8"
#define EMP_EXPORT_HEAD        NO      // 导出EMP数据是否添加头部数据
#define EMP_FIELD_DIV          "\0"   // EMP域分隔符
#define EMP_MAX_KEY_LEN        255     // EMP节点关键字最长限制
#define EMP_NAMEFLAG           '/'    // 名称和名称之间的分隔符
#define EMP_NAMEFLAG2          "/" 
#define EMP_POSFLAG            '|'    // 名称和位置之间的分隔符
#define EMP_POSFLAG2           "|"
#define EMP_POSFLAG3           "\\|"

static const int EMP_NODE_INDEX_FIRST = 1; // 第一个符合要求的节点索引
static const int EMP_NODE_INDEX_LAST = 0; // 最后一个符合要求的节点索引

struct _Head {
    int version;
    char encoding[20];
};

struct _Node {
    char name[10]; // the node key name
    NSData *value; // the node value
    Node *parent;
    Node *child0;
    Node *prev;
    Node *next;
    Node *attr0;
};

@interface LSDEMP2(PRIVATE)

- (void)nodesFree:(Node*)node;
- (Node*) getSibling:(Node*)child0 key:(char*)key index:(int)index;
- (Node*) getNodeLast:(Node*)node;
- (Node*)findNode:(const char*)path;
- (int)countSibling:(Node*)node;
- (void)writeRawVarint32:(NSMutableData*)output value:(int)value;
- (void)exportNode:(Node*)node output:(NSMutableData*)output;

@end

@implementation LSDEMP2

- (id)init
{
    if (self = [super init]) {
        pkgHead = (Head*)calloc(sizeof(Head), 1);
        pkgHead->version = EMP_VERSION;
        strcat(pkgHead->encoding, EMP_DEFAULT_ENCODING);
        
        rootNode = (Node*)calloc(sizeof(Node), 1);
    }
    return self;
}

- (void)dealloc
{
    free(pkgHead);
    [self nodesFree:rootNode];
    [super dealloc];
}

- (void)nodesFree:(Node*)node
{
    if (!node) return;
    
    if (node->child0) {
        [self nodesFree:node->child0];
        node->child0 = nil;
    }
    
    if (node->next) {
        [self nodesFree:node->next];
        node->next = nil;
    }
    
    node->value = nil;
    free(node);
}

- (boolean_t)addString:(NSString*)path value:(NSString*)value 
{
    NSData *data = nil;
    if (value) {
        data = [value dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [self addData:path value:data];
}

- (boolean_t)addInteger:(NSString*)path value:(int64_t)value 
{
    NSString *data = [NSString stringWithFormat:@"%lld", value];
    return [self addString:path value:data];
}

- (boolean_t)addBoolean:(NSString*)path value:(BOOL)value
{
    return [self addString:path value:(value==YES)?@"1":@"0"];
}

- (boolean_t)addFloat:(NSString*)path value:(float)value
{
    NSString *data = [NSString stringWithFormat:@"%f", value];
    return [self addString:path value:data];
}

- (Node*) getSibling:(Node*)child0 key:(char*)key index:(int)index
{
    Node* node_tmp;
    Node* node_last = nil;
    int count = 0;
    
    node_tmp = child0;
    while (node_tmp != nil) {
        if (strcmp(node_tmp->name, key) == 0) {
            count++;
            
            if (index == EMP_NODE_INDEX_LAST) {
                node_last = node_tmp;
            } else if (index == count) {
                return node_tmp;
            }
        }
        
        node_tmp = node_tmp->next;
    }
    
    return node_last;
}

- (Node*) getNodeLast:(Node*)node
{
    Node *node_tmp;
    
    node_tmp = node;
    while (node_tmp != nil) {
        if (node_tmp->next == nil) {
            return node_tmp;
        }
        
        node_tmp = node_tmp->next;
    }
    
    return nil;
}

- (boolean_t)addData:(NSString*)path value:(NSData*)data
{
    if (path == nil || path.length == 0)
        return  false;
    
    const char *pold = [path UTF8String];
    
    // 删除第一个'/'
	if (*pold == EMP_NAMEFLAG)
		pold++;
    
    //统计路径中包含的节点数并将'/'置为'\0'
    char *p;
    char *path_dup = strdup(pold);
	int node_count = 1;
	p = strchr(path_dup, EMP_NAMEFLAG);
	while (p) {
		node_count++;
		*p = 0;
		p++;
		p = strchr(p, EMP_NAMEFLAG);
	}
    
    Node *parent_node = rootNode;
    Node *node_temp = nil;
    char *pkey, keyname[10], keyindex[3];
    int index;
    
    pkey = path_dup;
    for (int i = 1; i <= node_count; i++) {
        strsplit(pkey, EMP_POSFLAG2, 1, keyname, sizeof(keyname));
        strsplit(pkey, EMP_POSFLAG2, 2, keyindex, sizeof(keyindex));
        
        if (!*keyindex)
            index = ((i == node_count) ? EMP_NODE_INDEX_LAST : EMP_NODE_INDEX_FIRST);
        else
            index = atoi(keyindex);
        
        node_temp = [self getSibling:parent_node->child0 key:keyname index:index];
        if (node_temp == nil || i == node_count) {
            // new node
            Node *new_node = (Node*)calloc(sizeof(Node), 1);
            strncpy(new_node->name, keyname, sizeof(new_node->name));
            if ((data != nil) && (data.length > 0) && (i == node_count)) {
                new_node->value = data;
            }
            new_node->parent = parent_node;
            new_node->child0 = nil;
            {
                if (parent_node->child0 == nil) {
                    parent_node->child0 = new_node;
                    new_node->prev = nil;
                    new_node->next = nil;
                } else if (node_temp == nil || index == EMP_NODE_INDEX_LAST) {
                    Node *node2 = [self getNodeLast:parent_node->child0];
                    new_node->prev = node2;
                    new_node->next = nil;
                    node2->next = new_node;
                } else if (node_temp->prev == nil) {
                    parent_node->child0 = new_node;
                    new_node->prev = nil;
                    new_node->next = node_temp;
                    node_temp->prev = new_node;
                } else {
                    new_node->prev = node_temp->prev;
                    new_node->next = node_temp;
                    node_temp->prev->next = new_node;
                    node_temp->prev = new_node;
                }
            }
            
            parent_node = new_node;
        } else {
            parent_node = node_temp;
        }
        
        //next node
        pkey += strlen(pkey) + 1;
    }
    
    free(path_dup);
    
    return true;
}

- (Node*)findNode:(const char*)path
{
    if (!path || !*path || *path == EMP_NAMEFLAG) {
        return rootNode->child0;
    }
    
    // 删除第一个'/'
    char *pold = (char*)path;
    if (*pold == EMP_NAMEFLAG)
		pold++;
    
    //统计路径中包含的节点数并将'/'置为'\0'
    char *p;
    char *path_dup = strdup(pold);
	int node_count = 1;
	p = strchr(path_dup, EMP_NAMEFLAG);
	while (p) {
		node_count++;
		*p = 0;
		p++;
		p = strchr(p, EMP_NAMEFLAG);
	}
    
    char *pkey, keyname[10], keyindex[3];
    int index = EMP_NODE_INDEX_FIRST;
    Node *child0 = rootNode->child0;
    Node *found = nil;
    
    pkey = path_dup;
    for (int i = 0; i < node_count; i++) {
        strsplit(pkey, EMP_POSFLAG2, 1, keyname, sizeof(keyname));
        strsplit(pkey, EMP_POSFLAG2, 2, keyindex, sizeof(keyindex));

        if (!*keyindex) {
            index = atoi(keyindex);
        }
        
        found = [self getSibling:child0 key:keyname index:index];
        // not found!
        if (found == nil)
            return nil;
        else
            child0 = found->child0;
    }
    
    return found;
}

- (int)countSibling:(Node*)node
{
    int n = 0;
    
    while (node != nil) {
        n++;
        node = node->next;
    }
    
    return n;
}

/**
 * Encode and write a varint. {@code value} is treated as unsigned, so it
 * won't be sign-extended if negative.
 */
- (void)writeRawVarint32:(NSMutableData*)output value:(int)value
{
    Byte b;
    while (true) {
        if ((value & ~0x7F) == 0) {
            b = (Byte)value;
            [output appendBytes:&b length:1];
            return;
        } else {
            b = (Byte)((value & 0x7F) | 0x80);
            [output appendBytes:&b length:1];
            value = ((unsigned)value) >> 7;
        }
    }
}

- (void)exportNode:(Node*)node output:(NSMutableData*)output
{
    int childCount;
    int8_t nodeType;
    
    if (node == nil)
        return;
    
    // node count
    childCount = [self countSibling:node];
    for (int i = 0; i < childCount; i++) {
        // node key
        [output appendBytes:node->name length:strlen(node->name)];
        [output appendBytes:EMP_FIELD_DIV length:1];
        
        // node type
        nodeType = 0x00;
        if (i == 0 && node->parent != rootNode) {
            nodeType |= 0x40;
        }
        if (i == childCount-1) {
            nodeType |= 0x20;
        }
        [output appendBytes:&nodeType length:1];
        
        // varint data size
        [self writeRawVarint32:output value:node->value.length];
        
        // node data
        [output appendData:node->value];
        
        // ignore attributes!!!
        
        // sub emp
        [self exportNode:node->child0 output:output];
        
        // node next
        node = node->next;
    }
}

- (NSData*)getBuffer
{
    return [self getBuffer:@""];
}

- (NSData*)getBuffer:(NSString*)path
{
    NSMutableData *outputData = [[[NSMutableData alloc] initWithCapacity:100] autorelease];
    
    if (EMP_EXPORT_HEAD) {
        //TODO...
    }
    
    Node *node = [self findNode:[path UTF8String]];
    if (node != nil) {
        [self exportNode:node output:outputData];
    }
    
    return outputData;
}

@end
