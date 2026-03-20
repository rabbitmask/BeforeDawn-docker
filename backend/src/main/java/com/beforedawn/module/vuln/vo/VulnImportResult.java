package com.beforedawn.module.vuln.vo;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class VulnImportResult {

    private Integer totalCount;
    private Integer successCount;
    private Integer failCount;
    private List<String> errors;

    public VulnImportResult() {
        this.totalCount = 0;
        this.successCount = 0;
        this.failCount = 0;
        this.errors = new ArrayList<>();
    }

    public void addError(String error) {
        this.errors.add(error);
    }

    public void incrementSuccess() {
        this.successCount++;
    }

    public void setTotalCount(Integer totalCount) {
        this.totalCount = totalCount;
    }

    public void setSuccessCount(Integer successCount) {
        this.successCount = successCount;
    }

    public void setFailCount(Integer failCount) {
        this.failCount = failCount;
    }

    public void setErrors(List<String> errors) {
        this.errors = errors;
    }

    public Integer getTotalCount() {
        return totalCount;
    }

    public Integer getSuccessCount() {
        return successCount;
    }

    public Integer getFailCount() {
        return failCount;
    }

    public List<String> getErrors() {
        return errors;
    }

    @Override
    public String toString() {
        return "VulnImportResult(totalCount=" + totalCount +
                ", successCount=" + successCount +
                ", failCount=" + failCount +
                ", errors=" + errors + ")";
    }
}
