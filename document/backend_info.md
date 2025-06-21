# Login System Go

一个使用Go语言开发的用户登录注册系统，包含密码哈希加密功能。

## 项目结构

```
login_sys_go/
├── config/
│   └── database.go          # 数据库配置
├── models/
│   └── user.go             # 用户模型和数据库操作
├── handlers/
│   └── auth.go             # 认证处理器
├── routes/
│   └── routes.go           # 路由配置
├── main.go                 # 主程序入口
├── go.mod                  # Go模块文件
├── test_register.py        # 注册功能测试脚本
├── test_login.py          # 登录功能测试脚本
├── instru.md              # 项目说明文档
└── README.md              # 项目README
```

## 功能特性

- ✅ 用户注册功能
- ✅ 用户登录功能
- ✅ 密码哈希加密（使用bcrypt）
- ✅ 用户名唯一性检查
- ✅ 用户账户状态管理
- ✅ RESTful API设计
- ✅ CORS支持
- ✅ 完整的错误处理
- ✅ Python测试脚本

## 技术栈

- **后端**: Go 1.21+
- **Web框架**: Gin
- **数据库**: MySQL
- **密码加密**: bcrypt
- **测试**: Python requests

## 数据库配置

### 数据库信息
- 主机: localhost
- 端口: 3306
- 用户名: root
- 密码: 123456
- 数据库名: login_sys

### 用户表结构
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID，主键',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名，唯一',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    is_active BOOLEAN DEFAULT TRUE COMMENT '账户是否激活'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户登录表';
```

## 安装和运行

### 1. 安装依赖
```bash
go mod tidy
```

### 2. 确保数据库运行
确保MySQL服务正在运行，并且已经创建了`login_sys`数据库和`users`表。

### 3. 启动服务器
```bash
go run main.go
```

服务器将在端口8000上启动。

## API接口

### 健康检查
```
GET /api/health
```

### 用户注册
```
POST /api/auth/register
Content-Type: application/json

{
    "username": "your_username",
    "password": "your_password"
}
```

### 用户登录
```
POST /api/auth/login
Content-Type: application/json

{
    "username": "your_username",
    "password": "your_password"
}
```

## 测试

### 运行注册测试
```bash
python test_register.py
```

### 运行登录测试
```bash
python test_login.py
```

### 测试用户信息
- 用户名: test
- 密码: 123456

## 响应格式

### 成功响应
```json
{
    "success": true,
    "message": "操作成功",
    "user": {
        "id": 1,
        "username": "test",
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z",
        "is_active": true
    }
}
```

### 错误响应
```json
{
    "success": false,
    "message": "错误信息"
}
```

## 状态码说明

- `200` - 登录成功
- `201` - 注册成功
- `400` - 请求格式错误
- `401` - 用户名或密码错误
- `403` - 用户账户未激活
- `409` - 用户名已存在
- `500` - 服务器内部错误

## 安全特性

1. **密码哈希**: 使用bcrypt算法对密码进行哈希加密
2. **用户名唯一性**: 确保用户名在系统中唯一
3. **账户状态管理**: 支持账户激活/停用功能
4. **输入验证**: 对用户输入进行严格验证
5. **错误处理**: 完善的错误处理机制

## 开发说明

- 项目遵循Go语言标准项目结构
- 使用依赖注入模式，便于测试和维护
- 分层架构设计：配置层、模型层、处理器层、路由层
- 所有密码都经过bcrypt哈希加密，不存储明文密码

## 注意事项

1. 确保MySQL服务正在运行
2. 确保数据库连接配置正确
3. 生产环境中请修改数据库密码
4. 建议在生产环境中使用HTTPS
5. 可以根据需要添加JWT令牌认证