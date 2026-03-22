# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Start development server
yarn dev
# or
npm run dev

# Build for production
yarn build
# or
npm run build

# Preview production build
yarn serve
# or
npm run serve
```

## Architecture

This is a Vue 3 single-page application (工作性价比计算器 - Job Cost-Performance Calculator) that calculates a job's "value score" based on salary, work hours, commute time, slack time, and various environment coefficients.

**Tech Stack:**
- Vue 3 with Composition API (script setup)
- Vite for build tooling
- Element Plus for UI components (form, input, select, button)
- Tailwind CSS for styling
- Vite legacy plugin for browser compatibility

**Project Structure:**
- `src/App.vue` - Single component containing all form logic, calculation formulas, and UI
- `src/main.js` - Vue app entry point with manual Element Plus component registration
- `config/vite.config.js` - Vite configuration with aliases (@ → src), legacy support, and Element Plus style imports
- `config/tailwind.config.js` - Tailwind CSS configuration
- `index.html` - HTML entry point

**Calculation Formula (App.vue:172-177):**
```
score = (salary / days * option1_coefficients / (35 * (workTime + roadTime - fishTime/2) * option1)) * option6
```

where `option1_coefficients = option2 * option3 * option4 * option5`

**Score Interpretation:**
- < 0.8: "很惨" (miserable)
- 0.8-1.5: "一般" (average)
- 1.5-2.0: "很爽" (great)
- > 2.0: "爽到爆炸" (excellent)

All form state, options arrays, and computed results are in `src/App.vue`. The component uses reactive state management with Vue's `reactive`, `computed`, and `watch`.

## ✨ 优化说明 (2026-03-22)

### 🎯 优化目标
1. ✅ 设置自适应尺寸，支持 PC 端和手机端完美打开
2. ✅ 优化 UI 设计，选项栏改为卡片样式

### 📝 优化内容

#### 1️⃣ 响应式布局优化
- **移除固定高度**: `h-screen` → `min-h-screen` (自适应)
- **响应式容器**: 添加 `max-w-6xl` 和 `px-4` 边距
- **响应式网格**: 
  - 输入字段: `grid-cols-1 md:grid-cols-2 lg:grid-cols-4` (1列→2列→4列)
  - 卡片区域: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3` (1列→2列→3列)
- **响应式字体**: `text-2xl md:text-4xl` 等
- **响应式间距**: `p-4 md:p-8`, `gap-4 md:gap-6` 等

#### 2️⃣ 卡片样式改造
- **视觉效果**: 
  - 渐变背景: `linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)`
  - 圆角阴影: 12px border-radius + box-shadow
  - 表情符号: 🎓 📊 💃 👥 📜 ⏰ (增强可读性)
- **交互效果**:
  - 悬停: 阴影增强 + 上升动画 (`translateY(-2px)`)
  - 选中: 蓝色渐变背景 + 白色文字 + 发光效果
  - 平滑过渡: `transition: all 0.2s ease`
- **实现方式**: 替换 `<el-select>` 为 `<button>` 组 + `v-for`

#### 3️⃣ 功能增强
- 新增 `reset()` 函数: 重置表单到初始状态
- 新增 `formSize` 计算属性: 动态表单大小
- 优化 `start()` 函数: 添加加载动画

### 📂 新增文件
- `test-responsive.html` - 响应式设计演示页面（可不依赖 Node.js 直接打开）
- `TEST_REPORT.md` - 详细测试报告及验证结果
- `OPTIMIZATION_SUMMARY.md` - 完整优化总结文档
- `QUICK_START.md` - 快速开始使用指南

### ✅ 测试验证
- ✅ 响应式布局: PC(1024px+)、平板(768px)、手机(<768px) 均通过
- ✅ 卡片样式: 悬停、点击、显示效果正常
- ✅ 功能完整: 计算、重置、数据验证均正常工作
- ✅ 浏览器兼容: Chrome、Firefox、Safari、Edge 全支持

### 🚀 部署建议
1. 运行 `npm install` 安装依赖
2. 运行 `npm run dev` 本地测试
3. 运行 `npm run build` 生成生产版本
4. 上传构建结果到服务器