-- ============================================
-- BeforeDawn 漏洞管理平台初始化数据SQL
-- ============================================

-- 设置字符集，避免中文乱码！
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

USE beforedawn_vuln;

-- ============================================
-- 1. 初始化部门数据
-- ============================================

-- 先清空表避免主键冲突
DELETE FROM `sys_department`;

INSERT INTO `sys_department` (`id`, `dept_name`, `parent_id`, `sort_order`, `status`) VALUES
(1, '总公司', 0, 1, 1),
(2, '技术部', 1, 2, 1),
(3, '安全部', 1, 3, 1),
(4, '产品部', 1, 4, 1);

-- ============================================
-- 2. 初始化管理员账号
-- ============================================

-- 先清空表避免主键冲突
DELETE FROM `sys_user`;

-- 默认密码：123456（BCrypt加密后）
-- $2a$10$YfrlCiAxdivRuZ7GjTT5Z.jKw4jgt/NgieyerGvbGzgJpetCk.f4S
INSERT INTO `sys_user` (`id`, `username`, `password`, `real_name`, `email`, `department_id`, `department_name`, `user_role`, `status`) VALUES
(1, 'admin', '$2a$10$YfrlCiAxdivRuZ7GjTT5Z.jKw4jgt/NgieyerGvbGzgJpetCk.f4S', '管理员', 'admin@beforedawn.com', 1, '总公司', 'admin', 1),
(2, 'security01', '$2a$10$YfrlCiAxdivRuZ7GjTT5Z.jKw4jgt/NgieyerGvbGzgJpetCk.f4S', '张三', 'security@beforedawn.com', 3, '安全部', 'security', 1),
(3, 'dev01', '$2a$10$YfrlCiAxdivRuZ7GjTT5Z.jKw4jgt/NgieyerGvbGzgJpetCk.f4S', '李四', 'dev@beforedawn.com', 2, '技术部', 'developer', 1);

-- ============================================
-- 3. 初始化字典类型数据
-- ============================================

-- 先清空表避免主键冲突
DELETE FROM `sys_dict_type`;

INSERT INTO `sys_dict_type` (`id`, `dict_code`, `dict_name`, `description`, `system_flag`, `sort_order`) VALUES
(1, 'vuln_source', '漏洞来源', '漏洞发现的来源渠道', 1, 1),
(2, 'vuln_type', '漏洞类型', '漏洞的具体类型分类', 1, 2),
(3, 'risk_level', '风险等级', '漏洞的危害等级分类', 1, 3),
(4, 'vuln_status', '漏洞状态', '漏洞处理的生命周期状态', 1, 4),
(5, 'asset_type', '资产类型', '信息资产的类型分类', 1, 5),
(6, 'business_level', '业务重要性', '资产或系统的业务重要程度', 1, 6),
(7, 'knowledge_category', '知识库分类', '知识库文章的类型分类', 1, 7);

-- ============================================
-- 4. 初始化字典数据
-- ============================================

-- 先清空表避免主键冲突
DELETE FROM `sys_dict_data`;

-- 4.1 漏洞来源（vuln_source）
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `dict_color`, `sort_order`, `system_flag`, `remark`) VALUES
(100001, 'vuln_source', '自查发现', 'self_check', 'blue', 1, 0, '安全团队日常自查发现的漏洞'),
(100002, 'vuln_source', '攻防演练', 'attack_defense', 'red', 2, 0, '攻防演练期间发现的漏洞'),
(100003, 'vuln_source', '上级通报', 'superior_report', 'orange', 3, 0, '上级单位或监管部门通报的漏洞'),
(100004, 'vuln_source', '渗透测试', 'penetration_test', 'purple', 4, 0, '专项渗透测试发现的漏洞'),
(100005, 'vuln_source', '代码审计', 'code_audit', 'green', 5, 0, '代码安全审计发现的漏洞'),
(100006, 'vuln_source', '安全扫描', 'security_scan', 'cyan', 6, 0, '自动化扫描工具发现的漏洞'),
(100007, 'vuln_source', '外部报告', 'external_report', 'yellow', 7, 0, '外部安全研究人员或白帽子报告'),
(100008, 'vuln_source', '用户反馈', 'user_feedback', 'gray', 8, 0, '用户反馈的安全问题'),
(100009, 'vuln_source', '应急响应', 'emergency', 'red', 9, 0, '安全事件应急响应中发现的漏洞'),
(100010, 'vuln_source', '其他', 'other', 'default', 99, 0, '其他来源');

-- 4.2 漏洞类型（vuln_type）
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `dict_color`, `sort_order`, `system_flag`, `remark`) VALUES
(100011, 'vuln_type', 'SQL注入', 'sql_injection', 'red', 1, 0, '数据库注入漏洞'),
(100012, 'vuln_type', 'XSS跨站脚本', 'xss', 'orange', 2, 0, '跨站脚本攻击漏洞'),
(100013, 'vuln_type', 'CSRF跨站请求伪造', 'csrf', 'yellow', 3, 0, '跨站请求伪造漏洞'),
(100014, 'vuln_type', '文件上传漏洞', 'file_upload', 'red', 4, 0, '任意文件上传漏洞'),
(100015, 'vuln_type', '文件包含漏洞', 'file_inclusion', 'orange', 5, 0, '本地/远程文件包含'),
(100016, 'vuln_type', '命令执行', 'command_injection', 'red', 6, 0, '系统命令注入漏洞'),
(100017, 'vuln_type', '代码执行', 'code_execution', 'red', 7, 0, '任意代码执行漏洞'),
(100018, 'vuln_type', '越权访问', 'broken_access_control', 'orange', 8, 0, '水平/垂直越权漏洞'),
(100019, 'vuln_type', '敏感信息泄露', 'info_disclosure', 'yellow', 9, 0, '敏感数据泄露'),
(100020, 'vuln_type', '弱口令', 'weak_password', 'blue', 10, 0, '弱口令或默认口令'),
(100021, 'vuln_type', '未授权访问', 'unauthorized_access', 'orange', 11, 0, '无需认证即可访问'),
(100022, 'vuln_type', 'XXE漏洞', 'xxe', 'orange', 12, 0, 'XML外部实体注入'),
(100023, 'vuln_type', 'SSRF漏洞', 'ssrf', 'orange', 13, 0, '服务端请求伪造'),
(100024, 'vuln_type', '反序列化漏洞', 'deserialization', 'red', 14, 0, '不安全的反序列化'),
(100025, 'vuln_type', '逻辑漏洞', 'business_logic', 'yellow', 15, 0, '业务逻辑漏洞'),
(100026, 'vuln_type', '配置错误', 'misconfiguration', 'blue', 16, 0, '安全配置不当'),
(100027, 'vuln_type', '中间件漏洞', 'middleware', 'orange', 17, 0, '中间件或组件漏洞'),
(100028, 'vuln_type', '其他', 'other', 'default', 99, 0, '其他类型漏洞');

-- 4.3 风险等级（risk_level）
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `dict_color`, `sort_order`, `system_flag`, `is_default`, `remark`) VALUES
(100029, 'risk_level', '严重', 'critical', 'red', 1, 1, 0, 'CVSS 9.0-10.0，可直接获取系统控制权'),
(100030, 'risk_level', '高危', 'high', 'orange', 2, 1, 0, 'CVSS 7.0-8.9，可导致数据泄露或系统瘫痪'),
(100031, 'risk_level', '中危', 'medium', 'yellow', 3, 1, 1, 'CVSS 4.0-6.9，需特定条件才能利用'),
(100032, 'risk_level', '低危', 'low', 'blue', 4, 1, 0, 'CVSS 0.1-3.9，危害较小'),
(100033, 'risk_level', '信息', 'info', 'gray', 5, 1, 0, '仅为信息性发现，无直接危害');

-- 4.4 漏洞状态（vuln_status）
-- 简化为三个状态：待修复、待复测、已完成
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `dict_color`, `sort_order`, `system_flag`, `remark`) VALUES
(100034, 'vuln_status', '待修复', 'assigned', 'warning', 1, 1, '已分配给开发人员待修复，包括新提交和复测不通过的漏洞'),
(100035, 'vuln_status', '待复测', 'fixed', 'primary', 2, 1, '开发人员已修复，等待安全人员复测'),
(100036, 'vuln_status', '已完成', 'closed', 'success', 3, 1, '安全人员复测通过，漏洞处理完成');

-- 4.5 资产类型（asset_type）
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `dict_icon`, `sort_order`, `system_flag`, `remark`) VALUES
(100037, 'asset_type', 'Web应用', 'web_application', 'icon-web', 1, 0, 'Web应用系统'),
(100038, 'asset_type', '移动应用', 'mobile_app', 'icon-mobile', 2, 0, 'Android/iOS应用'),
(100039, 'asset_type', '服务器主机', 'server_host', 'icon-server', 3, 0, '物理服务器或云主机'),
(100040, 'asset_type', '网络设备', 'network_device', 'icon-network', 4, 0, '路由器、交换机、防火墙等'),
(100041, 'asset_type', '域名', 'domain', 'icon-domain', 5, 0, '对外服务域名'),
(100042, 'asset_type', 'API接口', 'api', 'icon-api', 6, 0, 'RESTful API或WebService'),
(100043, 'asset_type', '数据库', 'database', 'icon-database', 7, 0, 'MySQL、Oracle、Redis等'),
(100044, 'asset_type', '其他', 'other', 'icon-other', 99, 0, '其他类型资产');

-- 4.6 业务重要性（business_level）
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `dict_color`, `sort_order`, `system_flag`, `remark`) VALUES
(100045, 'business_level', '核心业务', 'critical', 'red', 1, 0, '核心业务系统，不可中断'),
(100046, 'business_level', '重要业务', 'high', 'orange', 2, 0, '重要业务系统，影响较大'),
(100047, 'business_level', '一般业务', 'medium', 'blue', 3, 0, '一般业务系统'),
(100048, 'business_level', '辅助业务', 'low', 'gray', 4, 0, '辅助或测试系统');

-- 4.7 知识库分类（knowledge_category）
INSERT INTO `sys_dict_data` (`id`, `dict_type_code`, `dict_label`, `dict_value`, `sort_order`, `system_flag`, `remark`) VALUES
(100049, 'knowledge_category', '漏洞修复指南', 'fix_guide', 1, 0, '各类漏洞的修复方法'),
(100050, 'knowledge_category', '安全配置基线', 'security_baseline', 2, 0, '安全加固配置指南'),
(100051, 'knowledge_category', '历史案例分析', 'case_study', 3, 0, '历史漏洞案例分析'),
(100052, 'knowledge_category', '安全开发规范', 'dev_standard', 4, 0, '安全编码规范'),
(100053, 'knowledge_category', '工具使用教程', 'tool_tutorial', 5, 0, '安全工具使用教程'),
(100054, 'knowledge_category', '其他', 'other', 99, 0, '其他知识文章');

-- ============================================
-- 5. 知识库相关配置
-- 知识库分类已统一到字典管理（sys_dict_data中的knowledge_category类型）
-- ============================================

-- ============================================
-- 6. 初始化RBAC权限数据
-- 标准RBAC的角色、权限、关联关系初始化
-- ============================================

-- 6.1 初始化角色数据（3个系统内置角色）
INSERT INTO `sys_role` (`id`, `role_code`, `role_name`, `role_type`, `description`, `sort_order`, `status`) VALUES
(1, 'ADMIN', '管理员', 'system', '系统管理员，拥有所有权限', 1, 1),
(2, 'SECURITY', '安全人员', 'system', '安全团队成员，负责提交漏洞、复测漏洞', 2, 1),
(3, 'DEVELOPER', '开发人员', 'system', '开发团队成员，负责修复漏洞', 3, 1);

-- 6.2 初始化权限数据（按模块划分）

-- 6.2.1 系统管理模块权限
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `resource_path`, `icon`, `sort_order`) VALUES
(100, 'system', '系统管理', 'menu', 0, '/system', 'Setting', 100),
(101, 'system:user', '用户管理', 'menu', 100, '/system/user', 'User', 101),
(102, 'system:dept', '部门管理', 'menu', 100, '/system/department', 'OfficeBuilding', 102),
(103, 'system:role', '角色管理', 'menu', 100, '/system/role', 'Avatar', 103),
(104, 'system:permission', '权限管理', 'menu', 100, '/system/permission', 'Lock', 104),
(105, 'system:dict', '字典管理', 'menu', 100, '/system/dict', 'Notebook', 105),
(106, 'system:alarm', '告警管理', 'menu', 100, '/system/alarm', 'Bell', 106),
(107, 'system:log', '日志管理', 'menu', 100, '/system/log', 'Document', 107);

INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`) VALUES
(111, 'system:user:query', '查询用户', 'button', 101, 1),
(112, 'system:user:add', '新增用户', 'button', 101, 2),
(113, 'system:user:edit', '编辑用户', 'button', 101, 3),
(114, 'system:user:delete', '删除用户', 'button', 101, 4),
(121, 'system:dept:query', '查询部门', 'button', 102, 1),
(122, 'system:dept:add', '新增部门', 'button', 102, 2),
(123, 'system:dept:edit', '编辑部门', 'button', 102, 3),
(124, 'system:dept:delete', '删除部门', 'button', 102, 4),
(131, 'system:role:query', '查询角色', 'button', 103, 1),
(132, 'system:role:add', '新增角色', 'button', 103, 2),
(133, 'system:role:edit', '编辑角色', 'button', 103, 3),
(134, 'system:role:delete', '删除角色', 'button', 103, 4),
(141, 'system:permission:query', '查询权限', 'button', 104, 1),
(142, 'system:permission:add', '新增权限', 'button', 104, 2),
(143, 'system:permission:edit', '编辑权限', 'button', 104, 3),
(144, 'system:permission:delete', '删除权限', 'button', 104, 4),
(151, 'system:dict:query', '查询字典', 'button', 105, 1),
(152, 'system:dict:add', '新增字典', 'button', 105, 2),
(153, 'system:dict:edit', '编辑字典', 'button', 105, 3),
(154, 'system:dict:delete', '删除字典', 'button', 105, 4),
-- 告警管理
(161, 'system:alarm:query', '查询告警配置', 'button', 106, 1),
(162, 'system:alarm:add', '新增告警配置', 'button', 106, 2),
(163, 'system:alarm:edit', '编辑告警配置', 'button', 106, 3),
(164, 'system:alarm:delete', '删除告警配置', 'button', 106, 4),
(165, 'system:alarm:enable', '启停告警配置', 'button', 106, 5),
(166, 'system:alarm:test', '测试告警通知', 'button', 106, 6),
-- 日志管理
(171, 'system:log:login:query', '查询登录日志', 'button', 107, 1),
(172, 'system:log:login:delete', '删除登录日志', 'button', 107, 2),
(173, 'system:log:login:clear', '清空登录日志', 'button', 107, 3),
(174, 'system:log:operation:query', '查询操作日志', 'button', 107, 4),
(175, 'system:log:operation:delete', '删除操作日志', 'button', 107, 5),
(176, 'system:log:operation:clear', '清空操作日志', 'button', 107, 6);

-- 6.2.2 资产管理模块权限
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `resource_path`, `icon`, `sort_order`) VALUES
(200, 'asset', '资产管理', 'menu', 0, '/asset', 'Box', 200),
(201, 'asset:list', '资产列表', 'menu', 200, '/asset/list', 'List', 201);

INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`) VALUES
(211, 'asset:query', '查询资产', 'button', 201, 1),
(212, 'asset:add', '新增资产', 'button', 201, 2),
(213, 'asset:edit', '编辑资产', 'button', 201, 3),
(214, 'asset:delete', '删除资产', 'button', 201, 4),
(215, 'asset:import', '导入资产', 'button', 201, 5),
(216, 'asset:export', '导出资产', 'button', 201, 6),
-- 数据权限：控制数据查询范围
(217, 'asset:query:all', '查询所有资产', 'button', 201, 7),
(218, 'asset:query:own', '查询自己负责的资产', 'button', 201, 8);

-- 6.2.3 漏洞管理模块权限
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `resource_path`, `icon`, `sort_order`) VALUES
(300, 'vuln', '漏洞管理', 'menu', 0, '/vulnerability', 'WarnTriangleFilled', 300),
(301, 'vuln:list', '漏洞列表', 'menu', 300, '/vulnerability/list', 'List', 301),
(302, 'vuln:submit:menu', '提交漏洞', 'menu', 300, '/vulnerability/submit', 'Plus', 302),
(303, 'vuln:mytodo', '我的待办', 'menu', 300, '/vulnerability/mytodo', 'Tickets', 303);

INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`) VALUES
(311, 'vuln:query', '查询漏洞', 'button', 301, 1),
(312, 'vuln:submit:add', '提交漏洞', 'button', 302, 2),
(313, 'vuln:assign', '分派漏洞', 'button', 301, 3),
(314, 'vuln:fix', '修复漏洞', 'button', 303, 4),
(315, 'vuln:retest', '复测漏洞', 'button', 301, 5),
(316, 'vuln:delete', '删除漏洞', 'button', 301, 6),
(320, 'vuln:edit', '编辑漏洞', 'button', 301, 10),
-- 数据权限：控制数据查询范围
(317, 'vuln:query:all', '查询所有漏洞', 'button', 301, 7),
(318, 'vuln:query:created', '查询自己提交的漏洞', 'button', 301, 8),
(319, 'vuln:query:assigned', '查询分配给自己的漏洞', 'button', 301, 9);

-- 6.2.4 知识库模块权限
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `resource_path`, `icon`, `sort_order`) VALUES
(400, 'knowledge', '知识库', 'menu', 0, '/knowledge', 'Reading', 400),
(401, 'knowledge:article', '文章管理', 'menu', 400, '/knowledge/article', 'Document', 401),
-- 知识库分类统一使用字典管理，不再需要单独的分类管理页面
(403, 'knowledge:case', '漏洞案例', 'menu', 400, '/knowledge/case', 'Notebook', 403);

INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`) VALUES
(411, 'knowledge:query', '查询文章', 'button', 401, 1),
(412, 'knowledge:add', '新增文章', 'button', 401, 2),
(413, 'knowledge:edit', '编辑文章', 'button', 401, 3),
(414, 'knowledge:delete', '删除文章', 'button', 401, 4),
(415, 'knowledge:publish', '发布文章', 'button', 401, 5),
(431, 'knowledge:case:query', '查询漏洞案例', 'button', 403, 1);

-- 6.2.5 统计分析模块权限（仅ADMIN和SECURITY）
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `resource_path`, `icon`, `sort_order`) VALUES
(500, 'statistics', '统计分析', 'menu', 0, '/statistics', 'DataAnalysis', 500),
(501, 'statistics:overview', '漏洞总览', 'menu', 500, '/statistics/overview', 'Histogram', 501),
(502, 'statistics:ranking', '人员排行榜', 'menu', 500, '/statistics/ranking', 'TrendCharts', 502);

INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`) VALUES
(511, 'statistics:query', '查询统计数据', 'button', 501, 1);

-- 6.2.6 个人设置模块权限（所有人）
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `resource_path`, `icon`, `sort_order`) VALUES
(600, 'settings', '个人设置', 'menu', 0, '/settings', 'User', 600),
(601, 'settings:profile', '个人信息', 'menu', 600, '/settings/profile', NULL, 601),
(602, 'settings:security', '安全设置', 'menu', 600, '/settings/security', NULL, 602);

INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`) VALUES
(611, 'settings:profile:view', '查看个人信息', 'button', 601, 1),
(612, 'settings:profile:edit', '编辑个人信息', 'button', 601, 2),
(621, 'settings:password:change', '修改密码', 'button', 602, 1);


-- 6.2.7 文件管理模块权限（API接口权限，不是菜单）
INSERT INTO `sys_permission` (`id`, `permission_code`, `permission_name`, `permission_type`, `parent_id`, `sort_order`, `description`) VALUES
(711, 'file:upload', '上传文件', 'api', 0, 1, '允许用户上传文件（仅管理员和安全人员）'),
(712, 'file:delete', '删除文件', 'api', 0, 2, '允许用户删除文件（仅管理员和安全人员）');

-- 6.3 为3个系统角色分配权限

-- 6.3.1 管理员角色（拥有所有权限）
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`)
SELECT 1, id FROM `sys_permission`;

-- 6.3.2 安全人员角色
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`) VALUES
-- 资产管理（全部权限 + 查询所有资产）
(2, 200), (2, 201), (2, 211), (2, 212), (2, 213), (2, 214), (2, 215), (2, 216), (2, 217),
-- 漏洞管理（全部权限 + 查询所有漏洞 + 查询自己提交的漏洞）
(2, 300), (2, 301), (2, 302), (2, 303), (2, 311), (2, 312), (2, 313), (2, 314), (2, 315), (2, 316), (2, 317), (2, 318), (2, 320),
-- 知识库（全部权限，删掉了分类管理402，增加了漏洞案例403）
(2, 400), (2, 401), (2, 403), (2, 411), (2, 412), (2, 413), (2, 414), (2, 415), (2, 431),
-- 统计分析（全部权限）
(2, 500), (2, 501), (2, 502), (2, 511),
-- 个人设置（全部权限）
(2, 600), (2, 601), (2, 602), (2, 611), (2, 612), (2, 621),
-- 文件管理（上传+删除）
(2, 711), (2, 712);

-- 6.3.3 开发人员角色
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`) VALUES
-- 资产管理（只读 + 查询自己负责的资产）
(3, 200), (3, 201), (3, 211), (3, 218),
-- 漏洞管理（只读+我的待办可修复 + 查询分配给自己的漏洞）
(3, 300), (3, 301), (3, 303), (3, 311), (3, 314), (3, 319),
-- 知识库（只读，增加了漏洞案例403的查询权限431）
(3, 400), (3, 401), (3, 403), (3, 411), (3, 431),
-- 个人设置（全部权限）
(3, 600), (3, 601), (3, 602), (3, 611), (3, 612), (3, 621);

-- 6.4 为现有用户分配角色（根据user_role字段自动迁移）
INSERT INTO `sys_user_role` (`user_id`, `role_id`)
SELECT
    u.id,
    CASE
        WHEN u.user_role = 'admin' THEN 1
        WHEN u.user_role = 'security' THEN 2
        WHEN u.user_role = 'developer' THEN 3
        ELSE NULL
    END as role_id
FROM `sys_user` u
WHERE u.user_role IN ('admin', 'security', 'developer')
  AND NOT EXISTS (
      SELECT 1 FROM `sys_user_role` ur WHERE ur.user_id = u.id
  );

-- ============================================
-- 初始化数据SQL结束
-- 初始化数据全部插入完成！包括RBAC的角色、权限、关联关系！
-- 默认管理员账号：admin / 123456
-- ============================================
