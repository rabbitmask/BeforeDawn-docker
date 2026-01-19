-- ============================================
-- BeforeDawn 漏洞管理平台数据库建表SQL
-- 数据库：MySQL 8.0+
-- 字符集：utf8mb4
-- 排序规则：utf8mb4_general_ci
-- ============================================

-- 设置字符集，避免中文乱码！
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS beforedawn_vuln DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE beforedawn_vuln;

-- ============================================
-- 1. 系统管理模块
-- ============================================

-- 部门表
DROP TABLE IF EXISTS `sys_department`;
CREATE TABLE `sys_department` (
    `id` BIGINT NOT NULL COMMENT '部门ID（MyBatis-Plus雪花ID）',
    `dept_name` VARCHAR(100) NOT NULL COMMENT '部门名称',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父部门ID（0表示根部门）',
    `sort_order` INT DEFAULT 0 COMMENT '显示顺序',
    `leader_id` BIGINT COMMENT '部门负责人ID',
    `leader_name` VARCHAR(50) COMMENT '部门负责人姓名',
    `phone` VARCHAR(20) COMMENT '联系电话',
    `email` VARCHAR(100) COMMENT '邮箱',
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-正常 0-停用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_parent_id` (`parent_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- 用户表
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `id` BIGINT NOT NULL COMMENT '用户ID（MyBatis-Plus雪花ID）',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(200) NOT NULL COMMENT '密码（BCrypt加密）',
    `real_name` VARCHAR(50) COMMENT '真实姓名',
    `email` VARCHAR(100) COMMENT '邮箱',
    `phone` VARCHAR(20) COMMENT '手机号',
    `department_id` BIGINT COMMENT '主部门ID',
    `department_name` VARCHAR(100) COMMENT '主部门名称（冗余）',
    `user_role` VARCHAR(30) NOT NULL COMMENT '角色：ADMIN-管理员 SECURITY-安全人员 DEVELOPER-开发人员',
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    -- 统计字段（定期更新）
    `vuln_submitted_count` INT DEFAULT 0 COMMENT '提交漏洞数（安全人员）',
    `vuln_fixed_count` INT DEFAULT 0 COMMENT '修复漏洞数（开发人员）',
    `avg_fix_duration` DECIMAL(10,2) COMMENT '平均修复时长（分钟）',
    `retest_pass_rate` DECIMAL(5,2) COMMENT '修复通过率（%）=通过次数/修复次数',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    INDEX `idx_department` (`department_id`),
    INDEX `idx_user_role` (`user_role`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 字典类型表
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type` (
    `id` BIGINT NOT NULL COMMENT '字典类型ID（MyBatis-Plus雪花ID）',
    `dict_code` VARCHAR(100) NOT NULL COMMENT '字典编码（唯一标识）',
    `dict_name` VARCHAR(100) NOT NULL COMMENT '字典名称',
    `description` VARCHAR(500) COMMENT '字典描述',
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `system_flag` TINYINT DEFAULT 0 COMMENT '是否系统内置：1-是（不可删除） 0-否',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_dict_code` (`dict_code`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型表';

-- 字典数据表
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data` (
    `id` BIGINT NOT NULL COMMENT '字典数据ID（MyBatis-Plus雪花ID）',
    `dict_type_code` VARCHAR(100) NOT NULL COMMENT '字典类型编码',
    `dict_label` VARCHAR(100) NOT NULL COMMENT '字典标签（显示给用户）',
    `dict_value` VARCHAR(100) NOT NULL COMMENT '字典键值（存储到数据库）',
    `dict_color` VARCHAR(50) COMMENT '标签颜色（用于前端展示）',
    `dict_icon` VARCHAR(100) COMMENT '图标',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    `is_default` TINYINT DEFAULT 0 COMMENT '是否默认值：1-是 0-否',
    `remark` VARCHAR(500) COMMENT '备注',
    `system_flag` TINYINT DEFAULT 0 COMMENT '是否系统内置：1-是（不可删除） 0-否',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_type_value` (`dict_type_code`, `dict_value`),
    INDEX `idx_dict_type` (`dict_type_code`),
    INDEX `idx_status` (`status`),
    INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典数据表';

-- ============================================
-- 2. 资产管理模块
-- ============================================

-- 资产信息表
DROP TABLE IF EXISTS `asset_info`;
CREATE TABLE `asset_info` (
    `id` BIGINT NOT NULL COMMENT '资产ID（MyBatis-Plus雪花ID）',
    `asset_code` VARCHAR(100) NOT NULL COMMENT '资产编码（唯一标识）',
    `asset_name` VARCHAR(200) NOT NULL COMMENT '资产名称',
    `asset_type` VARCHAR(50) NOT NULL COMMENT '资产类型（字典：asset_type）',
    -- 网络信息
    `ip_address` VARCHAR(500) COMMENT 'IP地址（多个逗号分隔）',
    `domain` VARCHAR(200) COMMENT '域名',
    `port` VARCHAR(100) COMMENT '端口（如80,443）',
    `url` VARCHAR(500) COMMENT '访问地址',
    -- 责任信息
    `department_id` BIGINT NOT NULL COMMENT '所属部门ID',
    `department_name` VARCHAR(100) COMMENT '所属部门名称（冗余）',
    `owner_id` BIGINT NOT NULL COMMENT '主要负责人ID',
    `owner_name` VARCHAR(50) COMMENT '主要负责人姓名（冗余）',
    `backup_owner_id` BIGINT COMMENT '备用负责人ID',
    `backup_owner_name` VARCHAR(50) COMMENT '备用负责人姓名',
    -- 技术信息
    `tech_stack` VARCHAR(500) COMMENT '技术栈（如Java/Spring Boot/MySQL）',
    `framework` VARCHAR(200) COMMENT '框架版本',
    `deploy_env` VARCHAR(50) COMMENT '部署环境：production/staging/test/development',
    -- 业务信息
    `business_level` VARCHAR(50) COMMENT '业务重要性（字典：business_level）',
    `description` TEXT COMMENT '资产描述',
    `tags` VARCHAR(500) COMMENT '标签（逗号分隔）',
    -- 安全信息（自动计算）
    `risk_level` VARCHAR(20) COMMENT '风险等级：critical/high/medium/low/safe',
    `vuln_count` INT DEFAULT 0 COMMENT '关联漏洞总数（冗余字段）',
    `high_risk_vuln_count` INT DEFAULT 0 COMMENT '高危漏洞数（冗余字段）',
    `last_scan_time` DATETIME COMMENT '最后扫描时间',
    -- 状态管理
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-在用 2-下线 3-待上线',
    `online_time` DATETIME COMMENT '上线时间',
    `offline_time` DATETIME COMMENT '下线时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_asset_code` (`asset_code`),
    INDEX `idx_asset_type` (`asset_type`),
    INDEX `idx_department` (`department_id`),
    INDEX `idx_owner` (`owner_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_risk_level` (`risk_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产信息表';

-- ============================================
-- 3. 漏洞管理模块
-- ============================================

-- 漏洞信息表
DROP TABLE IF EXISTS `vuln_vulnerability`;
CREATE TABLE `vuln_vulnerability` (
    `id` BIGINT NOT NULL COMMENT '漏洞ID（MyBatis-Plus雪花ID）',
    `vuln_code` VARCHAR(50) NOT NULL COMMENT '漏洞编号：VULN-20250101-001',
    `title` VARCHAR(200) NOT NULL COMMENT '漏洞标题',
    `description` TEXT COMMENT '漏洞描述',
    `vuln_type` VARCHAR(50) COMMENT '漏洞类型（字典：vuln_type，用于关联知识库）',
    `risk_level` VARCHAR(20) NOT NULL COMMENT '风险等级（字典：risk_level）',
    `source_type` VARCHAR(50) NOT NULL COMMENT '来源类型（字典：vuln_source）',
    `status` VARCHAR(30) NOT NULL COMMENT '状态（字典：vuln_status）',
    `is_public` TINYINT DEFAULT 0 COMMENT '是否公开到漏洞案例：1-公开 0-不公开（仅closed状态可设置）',
    -- 资产关联
    `asset_id` BIGINT NOT NULL COMMENT '关联资产ID',
    `asset_name` VARCHAR(200) COMMENT '资产名称（冗余）',
    `asset_type` VARCHAR(50) COMMENT '资产类型（冗余）',
    -- 人员关联
    `submitter_id` BIGINT NOT NULL COMMENT '提交人ID（安全人员）',
    `submitter_name` VARCHAR(50) COMMENT '提交人姓名',
    `assignee_id` BIGINT COMMENT '分配给谁（开发人员）',
    `assignee_name` VARCHAR(50) COMMENT '处理人姓名',
    `department_id` BIGINT COMMENT '责任部门ID',
    `department_name` VARCHAR(100) COMMENT '责任部门名称',
    -- 时间字段（用于统计修复速度）
    `submit_time` DATETIME COMMENT '提交时间',
    `assign_time` DATETIME COMMENT '分派时间',
    `fix_deadline` DATETIME COMMENT '修复期限',
    `fix_submit_time` DATETIME COMMENT '提交修复时间',
    `retest_time` DATETIME COMMENT '复测时间',
    `close_time` DATETIME COMMENT '关闭时间',
    -- 复测相关统计字段
    `retest_count` INT DEFAULT 0 COMMENT '总复测次数',
    `retest_pass_count` INT DEFAULT 0 COMMENT '复测通过次数（正常应该只有1次）',
    `retest_fail_count` INT DEFAULT 0 COMMENT '复测失败次数',
    `current_retest_round` INT DEFAULT 0 COMMENT '当前复测轮次',
    -- 最后一次复测信息（冗余字段）
    `last_retest_time` DATETIME COMMENT '最后一次复测时间',
    `last_retest_result` VARCHAR(20) COMMENT '最后一次复测结果',
    `last_retest_opinion` TEXT COMMENT '最后一次复测意见',
    -- 修复相关
    `fix_count` INT DEFAULT 0 COMMENT '修复提交次数',
    `first_fix_time` DATETIME COMMENT '首次提交修复时间',
    `last_fix_time` DATETIME COMMENT '最后一次提交修复时间',
    `fix_duration` INT COMMENT '修复耗时（分钟）从分配到提交修复的时间',
    `is_overdue` TINYINT DEFAULT 0 COMMENT '是否超期：1-是 0-否',
    -- 知识库关联
    `related_knowledge_ids` VARCHAR(500) COMMENT '关联知识库ID列表，逗号分隔',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_vuln_code` (`vuln_code`),
    INDEX `idx_status` (`status`),
    INDEX `idx_risk_level` (`risk_level`),
    INDEX `idx_asset` (`asset_id`),
    INDEX `idx_assignee` (`assignee_id`),
    INDEX `idx_department` (`department_id`),
    INDEX `idx_submit_time` (`submit_time`),
    INDEX `idx_vuln_type` (`vuln_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='漏洞信息表';

-- 漏洞复测记录表
DROP TABLE IF EXISTS `vuln_retest_record`;
CREATE TABLE `vuln_retest_record` (
    `id` BIGINT NOT NULL COMMENT 'ID（MyBatis-Plus雪花ID）',
    `vuln_id` BIGINT NOT NULL COMMENT '漏洞ID',
    `vuln_code` VARCHAR(50) COMMENT '漏洞编号（冗余）',
    `retest_round` INT NOT NULL COMMENT '复测轮次（1,2,3...）',
    `retest_result` VARCHAR(20) NOT NULL COMMENT '复测结果：pass-通过 fail-未通过',
    `retest_time` DATETIME NOT NULL COMMENT '复测时间',
    `tester_id` BIGINT NOT NULL COMMENT '复测人ID（安全人员）',
    `tester_name` VARCHAR(50) COMMENT '复测人姓名（冗余）',
    `retest_opinion` TEXT COMMENT '复测意见（通过原因或失败原因）',
    `fail_reason` VARCHAR(500) COMMENT '失败原因分类',
    `attachment_urls` VARCHAR(1000) COMMENT '附件URL（复测截图、报告等，多个用逗号分隔）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_vuln` (`vuln_id`),
    INDEX `idx_round` (`vuln_id`, `retest_round`),
    INDEX `idx_tester` (`tester_id`),
    INDEX `idx_time` (`retest_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='漏洞复测记录表';

-- 漏洞操作日志表
DROP TABLE IF EXISTS `vuln_operation_log`;
CREATE TABLE `vuln_operation_log` (
    `id` BIGINT NOT NULL COMMENT 'ID（MyBatis-Plus雪花ID）',
    `vuln_id` BIGINT NOT NULL COMMENT '漏洞ID',
    `vuln_code` VARCHAR(50) COMMENT '漏洞编号（冗余）',
    `operation_type` VARCHAR(50) NOT NULL COMMENT '操作类型：create/assign/fix/retest/close等',
    `operation_desc` TEXT COMMENT '操作描述',
    `old_status` VARCHAR(30) COMMENT '操作前状态',
    `new_status` VARCHAR(30) COMMENT '操作后状态',
    `operator_id` BIGINT COMMENT '操作人ID',
    `operator_name` VARCHAR(50) COMMENT '操作人姓名',
    `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_vuln` (`vuln_id`),
    INDEX `idx_operation_type` (`operation_type`),
    INDEX `idx_operation_time` (`operation_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='漏洞操作日志表';

-- 漏洞附件表
DROP TABLE IF EXISTS `vuln_attachment`;
CREATE TABLE `vuln_attachment` (
    `id` BIGINT NOT NULL COMMENT 'ID（MyBatis-Plus雪花ID）',
    `vuln_id` BIGINT NOT NULL COMMENT '漏洞ID',
    `file_name` VARCHAR(200) NOT NULL COMMENT '文件名',
    `file_path` VARCHAR(500) NOT NULL COMMENT '文件路径',
    `file_size` BIGINT COMMENT '文件大小（字节）',
    `file_type` VARCHAR(50) COMMENT '文件类型',
    `upload_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    `uploader_id` BIGINT COMMENT '上传人ID',
    `uploader_name` VARCHAR(50) COMMENT '上传人姓名',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_vuln` (`vuln_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='漏洞附件表';

-- ============================================
-- 4. 系统配置模块
-- ============================================

-- ============================================
-- 5. 知识库模块
-- ============================================

-- 知识库分类统一使用字典管理（sys_dict_data中的knowledge_category类型）

-- 知识库文章表
DROP TABLE IF EXISTS `knowledge_article`;
CREATE TABLE `knowledge_article` (
    `id` BIGINT NOT NULL COMMENT '文章ID（MyBatis-Plus雪花ID）',
    `article_code` VARCHAR(50) NOT NULL COMMENT '文章编号：KB-20250101-001',
    `title` VARCHAR(200) NOT NULL COMMENT '文章标题',
    `summary` VARCHAR(500) COMMENT '文章摘要',
    `content` LONGTEXT NOT NULL COMMENT '文章内容（富文本HTML）',
    -- 分类信息（使用字典knowledge_category）
    `category` VARCHAR(50) COMMENT '分类（字典值：fix_guide/security_baseline/case_study等）',
    -- 关联信息（用于智能推荐）
    `vuln_type` VARCHAR(50) COMMENT '关联的漏洞类型（多个用逗号分隔）',
    `asset_type` VARCHAR(50) COMMENT '关联的资产类型（多个用逗号分隔）',
    `tech_stack` VARCHAR(200) COMMENT '关联的技术栈',
    `related_vuln_ids` VARCHAR(500) COMMENT '关联的历史漏洞ID列表（逗号分隔）',
    -- 作者信息
    `author_id` BIGINT NOT NULL COMMENT '作者ID',
    `author_name` VARCHAR(50) COMMENT '作者姓名',
    -- 统计信息
    `view_count` INT DEFAULT 0 COMMENT '浏览次数',
    `reference_count` INT DEFAULT 0 COMMENT '引用次数（被多少漏洞引用）',
    `useful_count` INT DEFAULT 0 COMMENT '有用评价数',
    -- 状态管理
    `status` VARCHAR(20) DEFAULT 'draft' COMMENT '状态：draft-草稿 published-已发布 archived-已归档',
    `publish_time` DATETIME COMMENT '发布时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_article_code` (`article_code`),
    INDEX `idx_category` (`category`),
    INDEX `idx_vuln_type` (`vuln_type`),
    INDEX `idx_status` (`status`),
    INDEX `idx_publish_time` (`publish_time`),
    FULLTEXT INDEX `ft_search` (`title`, `summary`, `content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库文章表';

-- ============================================
-- 建表SQL结束

-- ============================================
-- 6. RBAC权限管理模块
-- 标准RBAC设计，支持灵活的角色权限配置
-- ============================================

-- 角色表
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
    `id` BIGINT NOT NULL COMMENT '角色ID（MyBatis-Plus雪花ID）',
    `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码（唯一标识，如ADMIN、SECURITY）',
    `role_name` VARCHAR(100) NOT NULL COMMENT '角色名称（如：管理员、安全人员）',
    `role_type` VARCHAR(20) DEFAULT 'custom' COMMENT '角色类型：system-系统内置 custom-自定义',
    `description` VARCHAR(500) COMMENT '角色描述',
    `sort_order` INT DEFAULT 0 COMMENT '显示排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_code` (`role_code`),
    INDEX `idx_role_type` (`role_type`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 权限表
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission` (
    `id` BIGINT NOT NULL COMMENT '权限ID（MyBatis-Plus雪花ID）',
    `permission_code` VARCHAR(100) NOT NULL COMMENT '权限编码（唯一标识，如system:user:add）',
    `permission_name` VARCHAR(100) NOT NULL COMMENT '权限名称（如：新增用户）',
    `permission_type` VARCHAR(20) NOT NULL COMMENT '权限类型：menu-菜单 button-按钮 api-接口',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父权限ID（构建树形结构）',
    `resource_path` VARCHAR(500) COMMENT '资源路径（菜单路由path或API路径）',
    `method` VARCHAR(10) COMMENT 'HTTP方法（GET/POST/PUT/DELETE，仅api类型使用）',
    `icon` VARCHAR(100) COMMENT '图标（菜单使用）',
    `sort_order` INT DEFAULT 0 COMMENT '显示排序',
    `description` VARCHAR(500) COMMENT '权限描述',
    `status` TINYINT DEFAULT 1 COMMENT '状态：1-启用 0-禁用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_permission_code` (`permission_code`),
    INDEX `idx_parent_id` (`parent_id`),
    INDEX `idx_permission_type` (`permission_type`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限表';

-- 用户角色关联表
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_by` BIGINT COMMENT '创建人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
    INDEX `idx_user` (`user_id`),
    INDEX `idx_role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 角色权限关联表
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `permission_id` BIGINT NOT NULL COMMENT '权限ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `create_by` BIGINT COMMENT '创建人',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
    INDEX `idx_role` (`role_id`),
    INDEX `idx_permission` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限关联表';

-- ============================================
-- 7. 系统日志 & 告警管理
-- ============================================

-- 告警配置表（钉钉 Webhook）
DROP TABLE IF EXISTS `sys_alarm_config`;
CREATE TABLE `sys_alarm_config` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `webhook_url` VARCHAR(500) NOT NULL COMMENT '钉钉机器人Webhook地址',
    `secret` VARCHAR(200) COMMENT '密钥（可选，用于加签）',
    `enabled` TINYINT DEFAULT 1 COMMENT '是否启用：1-启用 0-禁用',
    `event_codes` VARCHAR(500) COMMENT '通知事件编码，逗号分隔（vuln_publish,vuln_retest,vuln_fix,article_publish,case_public,daily_summary）',
    `daily_enabled` TINYINT DEFAULT 0 COMMENT '是否启用每日汇总：1-启用 0-禁用',
    `daily_time` TIME COMMENT '每日推送时间（系统时间）',
    `last_daily_sent_date` DATE COMMENT '上一次每日汇总发送日期（防重复）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_enabled` (`enabled`),
    INDEX `idx_daily` (`daily_enabled`, `daily_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='告警配置表';

-- 登录日志表
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT COMMENT '用户ID（登录失败时可能为空）',
    `username` VARCHAR(50) COMMENT '用户名',
    `login_result` VARCHAR(20) NOT NULL COMMENT '登录结果：success/fail',
    `fail_reason` VARCHAR(200) COMMENT '失败原因',
    `ip` VARCHAR(50) COMMENT 'IP地址',
    `user_agent` VARCHAR(500) COMMENT 'User-Agent',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间（登录时间）',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_username` (`username`),
    INDEX `idx_user` (`user_id`),
    INDEX `idx_result_time` (`login_result`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志表';

-- 操作日志表
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT COMMENT '用户ID',
    `username` VARCHAR(50) COMMENT '用户名',
    `ip` VARCHAR(50) COMMENT 'IP地址',
    `user_agent` VARCHAR(500) COMMENT 'User-Agent',
    `http_method` VARCHAR(10) COMMENT 'HTTP方法',
    `request_path` VARCHAR(300) COMMENT '请求路径',
    `request_params` TEXT COMMENT '请求参数（摘要）',
    `success` TINYINT DEFAULT 1 COMMENT '是否成功：1-成功 0-失败',
    `error_message` VARCHAR(500) COMMENT '错误信息（失败时）',
    `cost_ms` BIGINT COMMENT '耗时（毫秒）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT COMMENT '创建人',
    `update_by` BIGINT COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_user` (`user_id`),
    INDEX `idx_success_time` (`success`, `create_time`),
    INDEX `idx_path` (`request_path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ============================================
-- 建表SQL结束
-- 24张表全部创建完成！（新增RBAC的4张表：角色、权限、用户角色关联、角色权限关联；新增3张：告警配置、登录日志、操作日志）
-- ============================================
