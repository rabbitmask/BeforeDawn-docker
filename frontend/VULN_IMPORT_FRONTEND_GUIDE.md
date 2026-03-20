# 前端批量导入功能修改指南

## 文件修改

### 1. 修改 vulnerability API 文件

在 `vulnerability-B7wVUV0D.js` 中添加 import 函数：

```javascript
import{as as e}from"./index-D-KiCPd7.js";
// ... 现有函数 ...

// 新增导入函数
function i(t){return e({url:"/vulnerability/import",method:"post",data:t,headers:{"Content-Type":"multipart/form-data"}})}
export{y as a,r as b,d as c,b as d,o as f,l as g,s as r,n as s,c as t,a as u,i as v};
```

### 2. 修改漏洞列表页面 (Vue 组件)

在漏洞列表页面 `views/vulnerability/index.vue` 中添加以下内容：

#### 2.1 添加导入按钮

在工具栏区域添加"批量导入"按钮：

```vue
<template>
  <div class="page-container">
    <div class="toolbar">
      <div class="toolbar-left">
        <!-- 现有按钮 -->
      </div>
      <div class="toolbar-right">
        <!-- 新增：批量导入按钮 -->
        <el-button type="success" @click="showImportDialog">
          <el-icon><Upload /></el-icon> 批量导入
        </el-button>
        <!-- 现有其他按钮 -->
      </div>
    </div>
    <!-- 列表内容 -->
  </div>
</template>
```

#### 2.2 添加导入对话框

在 `<template>` 区域添加导入对话框：

```vue
<template>
  <!-- 现有内容 -->
  
  <!-- 批量导入对话框 -->
  <el-dialog v-model="importDialogVisible" title="批量导入漏洞" width="500px">
    <div class="import-dialog-content">
      <el-upload
        ref="uploadRef"
        class="upload-demo"
        drag
        :action="importUrl"
        :headers="uploadHeaders"
        :on-success="handleImportSuccess"
        :on-error="handleImportError"
        :before-upload="beforeImportUpload"
        accept=".xlsx,.xls"
        :auto-upload="false"
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">拖拽文件到此处，或 <em>点击上传</em></div>
        <template #tip>
          <div class="el-upload__tip">
            <p>支持 .xlsx 和 .xls 格式的 Excel 文件</p>
            <p>请先下载 <el-link type="primary" :href="templateUrl">漏洞导入模板</el-link></p>
          </div>
        </template>
      </el-upload>
      
      <!-- 导入结果 -->
      <div v-if="importResult" class="import-result">
        <el-alert
          :title="`导入完成: 成功 ${importResult.successCount} 条, 失败 ${importResult.failCount} 条`"
          :type="importResult.failCount > 0 ? 'warning' : 'success'"
          :closable="false"
        />
        <div v-if="importResult.errors && importResult.errors.length > 0" class="import-errors">
          <p><strong>错误列表:</strong></p>
          <ul>
            <li v-for="(error, index) in importResult.errors" :key="index">{{ error }}</li>
          </ul>
        </div>
      </div>
    </div>
    <template #footer>
      <el-button @click="importDialogVisible = false">取消</el-button>
      <el-button type="primary" @click="submitImport">确定导入</el-button>
    </template>
  </el-dialog>
</template>
```

#### 2.3 添加脚本逻辑

在 `<script setup>` 中添加：

```javascript
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import { s as vulnImportApi } from './vulnerability-B7wVUV0D.js'

// 导入相关
const importDialogVisible = ref(false)
const uploadRef = ref(null)
const importResult = ref(null)
const importUrl = '/api/vulnerability/import'
const templateUrl = '/templates/vuln_import_template.xlsx'

const uploadHeaders = {
  Authorization: 'Bearer ' + localStorage.getItem('token')
}

const showImportDialog = () => {
  importResult.value = null
  importDialogVisible.value = true
}

const beforeImportUpload = (file) => {
  const isExcel = file.name.endsWith('.xlsx') || file.name.endsWith('.xls')
  const isLt10M = file.size / 1024 / 1024 < 10
  
  if (!isExcel) {
    ElMessage.error('只能上传 Excel 文件 (.xlsx, .xls)')
    return false
  }
  if (!isLt10M) {
    ElMessage.error('文件大小不能超过 10MB')
    return false
  }
  return true
}

const submitImport = async () => {
  if (!uploadRef.value) return
  
  uploadRef.value.submit()
}

const handleImportSuccess = (response) => {
  if (response.code === 200) {
    importResult.value = response.data
    ElMessage.success('导入完成')
    if (importResult.value.failCount === 0) {
      importDialogVisible.value = false
      // 刷新列表
      loadVulnList()
    }
  } else {
    ElMessage.error(response.message || '导入失败')
  }
}

const handleImportError = (error) => {
  ElMessage.error('导入失败: ' + (error.message || '未知错误'))
}
```

#### 2.4 添加样式

在 `<style>` 中添加：

```css
.import-dialog-content {
  padding: 10px 0;
}

.import-result {
  margin-top: 20px;
}

.import-errors {
  margin-top: 10px;
  max-height: 200px;
  overflow-y: auto;
  background: #f5f5f5;
  padding: 10px;
  border-radius: 4px;
}

.import-errors ul {
  margin: 5px 0 0 0;
  padding-left: 20px;
}

.import-errors li {
  color: #666;
  font-size: 12px;
  line-height: 1.6;
}
```

## 完整修改示例

请参考 `vulnerability_list_page_example.vue` 文件获取完整的漏洞列表页面代码示例。

## Excel 导入模板说明

### 模板字段

| 列序号 | 字段名 | 是否必填 | 说明 |
|--------|--------|----------|------|
| A | 漏洞标题 | 是 | 漏洞的简短描述（5-200字符） |
| B | 漏洞描述 | 否 | 漏洞的详细描述 |
| C | 漏洞类型 | 否 | 对应字典 vuln_type |
| D | 风险等级 | 是 | critical/high/medium/low |
| E | 来源类型 | 是 | manual/scanner/pentest 等 |
| F | 资产编码 | 是 | 系统中已有资产的编码 |

### 字典值参考

**风险等级 (risk_level)**:
- critical - 严重
- high - 高危
- medium - 中危
- low - 低危

**漏洞类型 (vuln_type)**:
- injection - 注入类
- xss - XSS跨站
- csrf - CSRF
- file-upload - 文件上传
- info-leak - 信息泄露
- auth-bypass - 权限绕过
- other - 其他

**来源类型 (vuln_source)**:
- manual - 人工发现
- scanner - 扫描器发现
- pentest - 渗透测试
- code-review - 代码审计
- threat-intel - 威胁情报
- other - 其他

## 注意事项

1. 资产编码必须与系统中已有的资产编码完全匹配
2. 风险等级和来源类型使用字典值（代码），不是显示名称
3. 导入失败时会显示具体是哪一行出了问题
4. 建议先下载模板，填写后再上传
