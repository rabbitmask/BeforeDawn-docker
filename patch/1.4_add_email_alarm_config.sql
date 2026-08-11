ALTER TABLE `sys_alarm_log`
    ADD COLUMN `channel_type` VARCHAR(20) DEFAULT 'WEBHOOK' COMMENT '告警通道：WEBHOOK / EMAIL' AFTER `config_name`,
    ADD COLUMN `recipient` VARCHAR(1000) DEFAULT NULL COMMENT '接收对象' AFTER `alarm_title`,
    ADD INDEX `idx_alarm_channel_type` (`channel_type`);

CREATE TABLE IF NOT EXISTS `sys_email_alarm_config` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `mail_host` VARCHAR(255) NOT NULL COMMENT 'SMTP 服务器',
    `mail_port` INT NOT NULL COMMENT 'SMTP 端口',
    `username` VARCHAR(255) NOT NULL COMMENT '认证账号',
    `password` VARCHAR(255) DEFAULT NULL COMMENT '认证密码',
    `sender_name` VARCHAR(100) NOT NULL COMMENT '发件人名称',
    `sender_email` VARCHAR(255) NOT NULL COMMENT '发件邮箱',
    `ssl_enabled` TINYINT DEFAULT 0 COMMENT '是否启用 SSL',
    `starttls_enabled` TINYINT DEFAULT 0 COMMENT '是否启用 STARTTLS',
    `enabled` TINYINT DEFAULT 1 COMMENT '是否启用：1-启用 0-禁用',
    `event_codes` VARCHAR(500) DEFAULT NULL COMMENT '订阅事件编码，逗号分隔',
    `daily_enabled` TINYINT DEFAULT 0 COMMENT '是否启用每日报告：1-启用 0-禁用',
    `daily_time` TIME DEFAULT NULL COMMENT '每日报告发送时间',
    `last_daily_sent_date` DATE DEFAULT NULL COMMENT '上次每日报告发送日期',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `create_by` BIGINT DEFAULT NULL COMMENT '创建人',
    `update_by` BIGINT DEFAULT NULL COMMENT '更新人',
    PRIMARY KEY (`id`),
    INDEX `idx_email_alarm_enabled` (`enabled`),
    INDEX `idx_email_alarm_daily` (`daily_enabled`, `daily_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邮箱告警配置表';
