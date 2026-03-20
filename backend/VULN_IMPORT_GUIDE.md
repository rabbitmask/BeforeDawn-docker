# 漏洞批量导入功能修改指南

## 概述
本指南用于在现有 BeforeDawn 漏洞管理平台中添加批量导入漏洞功能。

## 需要修改的文件

### 后端 (Java/Spring Boot)

#### 1. 新增文件
- `module/vuln/vo/VulnImportVO.java` - 漏洞导入VO类（已创建）
- `module/vuln/vo/VulnImportResult.java` - 导入结果类（已创建）

#### 2. 需要修改的文件
- `module/vuln/controller/VulnerabilityController.java` - 添加 importVulns 接口
- `module/vuln/service/VulnerabilityService.java` - 添加 importVulns 方法声明
- `module/vuln/service/impl/VulnerabilityServiceImpl.java` - 实现导入逻辑

### 前端 (Vue.js)
- 需要在漏洞列表页面添加"批量导入"按钮和导入对话框

## 后端修改详解

### VulnerabilityController.java 修改

在现有的 VulnerabilityController 类中添加以下方法：

```java
@PostMapping("/import")
@PreAuthorize("hasAuthority('vuln:import')")
public Result<VulnImportResult> importVulns(@RequestParam("file") MultipartFile file) {
    log.info("开始导入漏洞文件: {}", file.getOriginalFilename());
    
    String filename = file.getOriginalFilename();
    if (filename == null || (!filename.endsWith(".xlsx") && !filename.endsWith(".xls"))) {
        return Result.error("请上传 Excel 文件(.xlsx 或 .xls)");
    }
    
    try {
        VulnImportResult result = vulnerabilityService.importVulns(file);
        log.info("漏洞导入完成, 成功: {}, 失败: {}", result.getSuccessCount(), result.getFailCount());
        return Result.success(result);
    } catch (Exception e) {
        log.error("漏洞导入失败", e);
        return Result.error("导入失败: " + e.getMessage());
    }
}
```

### VulnerabilityService.java 修改

在接口中添加方法声明：

```java
VulnImportResult importVulns(MultipartFile file);
```

### VulnerabilityServiceImpl.java 修改

实现 importVulns 方法的核心逻辑（参考 AssetServiceImpl 的实现）：

```java
@Override
public VulnImportResult importVulns(MultipartFile file) {
    VulnImportResult result = new VulnImportResult();
    List<VulnImportVO> dataList = new ArrayList<>();
    
    try {
        EasyExcel.read(file.getInputStream(), VulnImportVO.class, new ReadListener<VulnImportVO>() {
            @Override
            public void invokeHead(Map<Integer, Head> headMap, AnalysisContext context) {
            }
            
            @Override
            public void invoke(VulnImportVO data, AnalysisContext context) {
                dataList.add(data);
            }
            
            @Override
            public void doAfterAllAnalysed(AnalysisContext context) {
            }
        }).sheet().doRead();
        
        result.setTotalCount(dataList.size());
        
        for (int i = 0; i < dataList.size(); i++) {
            VulnImportVO importVO = dataList.get(i);
            int rowNum = i + 1;
            
            try {
                // 1. 校验必填字段
                if (!StringUtils.hasText(importVO.getTitle())) {
                    throw new BusinessException("第" + rowNum + "行: 漏洞标题不能为空");
                }
                if (!StringUtils.hasText(importVO.getAssetCode())) {
                    throw new BusinessException("第" + rowNum + "行: 资产编码不能为空");
                }
                if (!StringUtils.hasText(importVO.getRiskLevel())) {
                    throw new BusinessException("第" + rowNum + "行: 风险等级不能为空");
                }
                if (!StringUtils.hasText(importVO.getSourceType())) {
                    throw new BusinessException("第" + rowNum + "行: 来源类型不能为空");
                }
                
                // 2. 校验资产是否存在
                AssetInfo asset = assetInfoMapper.selectOne(
                    new LambdaQueryWrapper<AssetInfo>().eq(AssetInfo::getAssetCode, importVO.getAssetCode())
                );
                if (asset == null) {
                    throw new BusinessException("第" + rowNum + "行: 资产编码不存在");
                }
                
                // 3. 校验字典值
                // vulnType
                if (StringUtils.hasText(importVO.getVulnType())) {
                    DictData vulnTypeDict = dictDataMapper.selectOne(
                        new LambdaQueryWrapper<DictData>()
                            .eq(DictData::getDictTypeCode, "vuln_type")
                            .eq(DictData::getDictValue, importVO.getVulnType())
                    );
                    if (vulnTypeDict == null) {
                        throw new BusinessException("第" + rowNum + "行: 漏洞类型不存在");
                    }
                }
                
                // riskLevel
                DictData riskLevelDict = dictDataMapper.selectOne(
                    new LambdaQueryWrapper<DictData>()
                        .eq(DictData::getDictTypeCode, "risk_level")
                        .eq(DictData::getDictValue, importVO.getRiskLevel())
                );
                if (riskLevelDict == null) {
                    throw new BusinessException("第" + rowNum + "行: 风险等级不存在");
                }
                
                // sourceType
                DictData sourceTypeDict = dictDataMapper.selectOne(
                    new LambdaQueryWrapper<DictData>()
                        .eq(DictData::getDictTypeCode, "vuln_source")
                        .eq(DictData::getDictValue, importVO.getSourceType())
                );
                if (sourceTypeDict == null) {
                    throw new BusinessException("第" + rowNum + "行: 来源类型不存在");
                }
                
                // 4. 创建漏洞
                Vulnerability vulnerability = new Vulnerability();
                vulnerability.setTitle(importVO.getTitle());
                vulnerability.setDescription(importVO.getDescription());
                vulnerability.setVulnType(importVO.getVulnType());
                vulnerability.setRiskLevel(importVO.getRiskLevel());
                vulnerability.setSourceType(importVO.getSourceType());
                vulnerability.setAssetId(asset.getId());
                vulnerability.setAssetName(asset.getAssetName());
                vulnerability.setAssetType(asset.getAssetType());
                vulnerability.setStatus("assigned");
                vulnerability.setSubmitterId(SecurityUtils.getCurrentUserId());
                vulnerability.setSubmitterName(SecurityUtils.getCurrentUser().getRealName());
                vulnerability.setAssigneeId(asset.getOwnerId());
                vulnerability.setAssigneeName(asset.getOwnerName());
                vulnerability.setDepartmentId(asset.getDepartmentId());
                vulnerability.setDepartmentName(asset.getDepartmentName());
                vulnerability.setSubmitTime(LocalDateTime.now());
                vulnerability.setIsPublic(0);
                
                // 生成漏洞编号
                String vulnCode = generateVulnCode();
                vulnerability.setVulnCode(vulnCode);
                
                vulnerabilityMapper.insert(vulnerability);
                result.incrementSuccess();
                
            } catch (Exception e) {
                result.addError(e.getMessage());
            }
        }
        
        result.setFailCount(result.getErrors().size());
        
    } catch (IOException e) {
        log.error("读取Excel文件失败", e);
        throw new BusinessException("读取Excel文件失败: " + e.getMessage());
    }
    
    return result;
}
```

## Excel 模板字段说明

| 字段名 | 是否必填 | 说明 | 示例 |
|--------|----------|------|------|
| 漏洞标题 | 是 | 漏洞的简短描述 | SQL注入漏洞 |
| 漏洞描述 | 否 | 漏洞的详细描述 | 某个参数存在SQL注入 |
| 漏洞类型 | 否 | 字典值：vuln_type | injection |
| 风险等级 | 是 | 字典值：risk_level | high |
| 来源类型 | 是 | 字典值：vuln_source | manual |
| 资产编码 | 是 | 已有资产的编码 | ASSET-001 |

## 字典值参考

### risk_level (风险等级)
- critical - 严重
- high - 高危
- medium - 中危
- low - 低危

### vuln_type (漏洞类型)
- injection - 注入类
- xss - XSS跨站
- csrf - CSRF
- file-upload - 文件上传
- 信息泄露 - info-leak
- 权限绕过 - auth-bypass
- 其他 - other

### vuln_source (来源类型)
- manual - 人工发现
- scanner - 扫描器发现
-渗透测试 - pentest
- 代码审计 - code-review
- 威胁情报 - threat-intel
- 其他 - other

## 权限配置

需要在 sys_permission 表中添加以下权限记录：

```sql
INSERT INTO sys_permission (id, permission_code, permission_name, permission_type, parent_id, resource_path, method, sort_order, status, create_time, update_time)
VALUES (新的ID, 'vuln:import', '导入漏洞', 'api', 父权限ID, '/api/vulnerability/import', 'POST', 排序值, 1, NOW(), NOW());
```

## 编译和部署

1. 将新的 Java 文件复制到对应的源码目录
2. 修改现有的类文件添加新方法
3. 重新编译： `mvn clean package -DskipTests`
4. 替换 backend/app.jar 文件
5. 重启后端服务
