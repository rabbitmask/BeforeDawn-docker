package com.beforedawn.module.vuln.vo;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

@Data
public class VulnImportVO {

    @ExcelProperty(value = "漏洞标题", index = 0)
    private String title;

    @ExcelProperty(value = "漏洞描述", index = 1)
    private String description;

    @ExcelProperty(value = "漏洞类型", index = 2)
    private String vulnType;

    @ExcelProperty(value = "风险等级", index = 3)
    private String riskLevel;

    @ExcelProperty(value = "来源类型", index = 4)
    private String sourceType;

    @ExcelProperty(value = "资产编码", index = 5)
    private String assetCode;
}
