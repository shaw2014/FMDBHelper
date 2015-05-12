# FMDBHelper
ORM + 数据库 数据存储


服务端数据返回转成model，model再存入数据，增删改查，只需一步完成
结合了ORM框架Mantle和FMDB（demo中需要Pod下这两个第三方框架）

用法：创建一个集成MTLModel的类并实现MTLJSONSerializing,MTLFMDBSerializing这两个协议
@interface demoModel : MTLModel<MTLJSONSerializing,MTLFMDBSerializing>
@property (nonatomic,copy) NSString *xxxxx
....

//创建表
[[DBHelper helper] createTableWithModel:info];

//新增数据
[[DBHelper helper] insertTableWithModel:info];

//修改数据
[[DBHelper helper] updateTableWithModel:info];

//查询数据
[[DBHelper helper] selectFromTableWithModel:info];
