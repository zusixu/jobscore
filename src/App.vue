<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50 px-4 py-8 md:py-12">
    <!-- 头部容器 -->
    <div class="mx-auto max-w-6xl">
      <!-- 标题 -->
      <h1 class="text-2xl md:text-4xl font-bold text-center text-gray-800 mb-8">
        💼 工作性价比计算器
      </h1>

      <!-- 结果展示区域 -->
      <div class="result bg-white rounded-xl shadow-md p-4 md:p-6 mb-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="flex flex-col items-center justify-center p-4 bg-gradient-to-r from-red-50 to-pink-50 rounded-lg">
            <span class="text-sm text-gray-600 mb-2">工作性价比</span>
            <span v-if="state.status !== 'init'" class="font-bold text-3xl md:text-4xl text-red-500">
              {{text}}
            </span>
            <span v-else class="text-lg text-gray-400">待计算</span>
          </div>
          <div class="flex flex-col items-center justify-center p-4 bg-gradient-to-r from-blue-50 to-cyan-50 rounded-lg">
            <span class="text-sm text-gray-600 mb-2">得分</span>
            <span v-if="state.status !== 'init'" class="font-bold text-3xl md:text-4xl text-blue-500">
              {{result}}
            </span>
            <span v-else class="text-lg text-gray-400">待计算</span>
          </div>
        </div>
      </div>

      <!-- 表单容器 -->
      <div class="bg-white rounded-xl shadow-lg p-6 md:p-8 mb-8">
        <el-form :model="state.form" :size="formSize" class="form-container">
          <!-- 第一行: 基础信息 -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-8">
            <div>
              <label class="text-sm font-semibold text-gray-700 mb-2 block">月薪</label>
              <el-form-item prop="salary">
                <el-input-number 
                  :controls="state.controls" 
                  v-model="state.form.salary" 
                  :min="0"
                  placeholder="请输入月薪"
                  class="w-full"
                ></el-input-number>
              </el-form-item>
            </div>
            <div>
              <label class="text-sm font-semibold text-gray-700 mb-2 block">工作时长（小时）</label>
              <el-form-item prop="workTime">
                <el-input-number 
                  :controls="state.controls" 
                  v-model="state.form.workTime" 
                  :min="0" 
                  :max="24"
                  class="w-full"
                ></el-input-number>
              </el-form-item>
            </div>
            <div>
              <label class="text-sm font-semibold text-gray-700 mb-2 block">通勤时长（小时）</label>
              <el-form-item prop="roadTime">
                <el-input-number 
                  :controls="state.controls" 
                  v-model="state.form.roadTime" 
                  :min="0" 
                  :max="24"
                  class="w-full"
                ></el-input-number>
              </el-form-item>
            </div>
            <div>
              <label class="text-sm font-semibold text-gray-700 mb-2 block">摸鱼时长（小时）</label>
              <el-form-item prop="fishTime">
                <el-input-number 
                  :controls="state.controls" 
                  v-model="state.form.fishTime" 
                  :min="0" 
                  :max="24"
                  class="w-full"
                ></el-input-number>
              </el-form-item>
            </div>
            <div>
              <label class="text-sm font-semibold text-gray-700 mb-2 block">每月工作天数</label>
              <el-form-item prop="days">
                <el-input-number 
                  :controls="state.controls" 
                  v-model="state.form.days" 
                  :min="0" 
                  :max="31"
                  class="w-full"
                ></el-input-number>
              </el-form-item>
            </div>
          </div>

          <!-- 选项卡片区域 -->
          <h2 class="text-lg md:text-xl font-bold text-gray-800 mb-6">系数选择</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
            <!-- 学历系数 -->
            <div class="card-container">
              <h3 class="card-title">🎓 学历系数</h3>
              <el-form-item prop="option1">
                <div class="card-options">
                  <button
                    v-for="item in options1"
                    :key="item.value"
                    @click="state.form.option1 = item.value"
                    :class="['option-card', { active: state.form.option1 === item.value }]"
                  >
                    {{ item.label }}
                  </button>
                </div>
              </el-form-item>
            </div>

            <!-- 工作环境系数 -->
            <div class="card-container">
              <h3 class="card-title">🏢 工作环境</h3>
              <el-form-item prop="option2">
                <div class="card-options">
                  <button
                    v-for="item in options2"
                    :key="item.value"
                    @click="state.form.option2 = item.value"
                    :class="['option-card', { active: state.form.option2 === item.value }]"
                  >
                    {{ item.label }}
                  </button>
                </div>
              </el-form-item>
            </div>

            <!-- 异性环境系数 -->
            <div class="card-container">
              <h3 class="card-title">💃 异性环境</h3>
              <el-form-item prop="option3">
                <div class="card-options">
                  <button
                    v-for="item in options3"
                    :key="item.value"
                    @click="state.form.option3 = item.value"
                    :class="['option-card', { active: state.form.option3 === item.value }]"
                  >
                    {{ item.label }}
                  </button>
                </div>
              </el-form-item>
            </div>

            <!-- 同事环境系数 -->
            <div class="card-container">
              <h3 class="card-title">👥 同事环境</h3>
              <el-form-item prop="option4">
                <div class="card-options">
                  <button
                    v-for="item in options4"
                    :key="item.value"
                    @click="state.form.option4 = item.value"
                    :class="['option-card', { active: state.form.option4 === item.value }]"
                  >
                    {{ item.label }}
                  </button>
                </div>
              </el-form-item>
            </div>

            <!-- 职业资格系数 -->
            <div class="card-container">
              <h3 class="card-title">📜 职业资格</h3>
              <el-form-item prop="option5">
                <div class="card-options">
                  <button
                    v-for="item in options5"
                    :key="item.value"
                    @click="state.form.option5 = item.value"
                    :class="['option-card', { active: state.form.option5 === item.value }]"
                  >
                    {{ item.label }}
                  </button>
                </div>
              </el-form-item>
            </div>

            <!-- 早起系数 -->
            <div class="card-container">
              <h3 class="card-title">⏰ 是否8:30前上班</h3>
              <el-form-item prop="option6">
                <div class="card-options">
                  <button
                    v-for="item in options6"
                    :key="item.value"
                    @click="state.form.option6 = item.value"
                    :class="['option-card', { active: state.form.option6 === item.value }]"
                  >
                    {{ item.label }}
                  </button>
                </div>
              </el-form-item>
            </div>
          </div>

          <!-- 按钮 -->
          <div class="flex justify-center mt-8 gap-4">
            <el-button 
              type="primary" 
              @click="start()"
              size="large"
              class="px-8"
            >
              📊 计算性价比
            </el-button>
            <el-button 
              @click="reset()"
              size="large"
              class="px-8"
            >
              🔄 重置
            </el-button>
          </div>
        </el-form>
      </div>

      <!-- Footer -->
      <div class="flex justify-center items-center gap-4 py-8">
        <a href="https://github.com/biuuu/job-score" target="_blank" class="text-gray-600 hover:text-gray-900 transition">
          <svg class="octicon octicon-mark-github" height="32" viewBox="0 0 16 16" version="1.1" width="32" aria-hidden="true"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>
        </a>
        <span class="text-gray-600">欢迎 Star 和提交问题</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, computed, watch } from 'vue'

const state = reactive({
  status: 'init',
  form: {
    salary: 7000,
    days: 22,
    workTime: 8,
    roadTime: 1,
    fishTime: 4,
    option1: 1,
    option2: 1,
    option3: 1,
    option4: 1,
    option5: 1,
    option6: 1,
    option7: 1
  },
  controls: false
})
const options1 = [
  { label: '专科及以下', value: 0.8 },
  { label: '普通本科', value: 1 },
  { label: '高级本科', value: 1.2 },
  { label: '普通硕士', value: 1.4 },
  { label: '高级硕士', value: 1.6 },
  { label: '普通博士', value: 1.8 },
  { label: '高级博士', value: 2 }
]
const options2 = [
  { label: '偏僻地区', value: 0.8 },
  { label: '工厂户外', value: 0.9 },
  { label: '普通', value: 1 },
  { label: '体制内', value: 1.1 }
]
const options3 = [
  { label: '没有', value: 0.9 },
  { label: '不多不少', value: 1 },
  { label: '很多', value: 1.1 }
]
const options4 = [
  { label: 'SB很多', value: 0.95 },
  { label: '普通很多', value: 1 },
  { label: '优秀很多', value: 1.05 }
]
const options5 = [
  {　label: '无要求', value: 1　},
  {　label: '建造造价监理', value: 1.05　},
  {　label: '建筑岩土结构', value: 1.1　},
  {　label: '主任医师、教授', value: 1.15　}
]
const options6 = [
  { label: '是', value: 0.95 },
  { label: '否', value: 1 }
]
const options7 = [
  { label: '一线城市', value: 1.5 },
  { label: '城市', value: 1.2 },
  { label: '小城市', value: 1 },
  { label: '镇村', value: 0.8 }
]

const result = computed(() => {
  const data = state.form
  const val1 = data.option2 * data.option3 * data.option4 * data.option5
  const val2 = 35 * (data.workTime + data.roadTime - data.fishTime / 2) * data.option1
  return (data.salary / data.days * val1 / val2 * data.option6).toFixed(2)
})

const text = computed(() => {
  if (result.value < 0.8) {
    return '很惨'
  } else if (result.value < 1.5) {
    return '一般'
  } else if (result.value < 2) {
    return '很爽'
  } else {
    return '爽到爆炸'
  }
})

watch(state.form, () => {
  const data = state.form
  if (data.workTime + data.roadTime > 24) {
    state.form.workTime = 24 - data.roadTime
  }
  if (data.fishTime > data.workTime) {
    state.form.fishTime = data.workTime
  }
})

const formSize = computed(() => {
  // 根据需要返回合适的大小
  return 'default'
})

const start = () => {
  state.status = 'running'
  // 模拟计算过程
  setTimeout(() => {
    state.status = 'done'
  }, 300)
}

const reset = () => {
  state.form = {
    salary: 7000,
    days: 22,
    workTime: 8,
    roadTime: 1,
    fishTime: 4,
    option1: 1,
    option2: 1,
    option3: 1,
    option4: 1,
    option5: 1,
    option6: 1,
    option7: 1
  }
  state.status = 'init'
}
</script>

<style scoped>
.result {
  font-family: 宋体;
}

.el-input-number {
  width: 100% !important;
}

.el-select {
  width: 100% !important;
}

/* 卡片容器样式 */
.card-container {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  border-radius: 12px;
  padding: 18px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.card-container:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-options {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.option-card {
  padding: 10px 14px;
  border: 2px solid #e8eef5;
  border-radius: 8px;
  background: white;
  color: #333;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
  text-align: left;
}

.option-card:hover {
  border-color: #409eff;
  background-color: #f0f9ff;
  transform: translateX(4px);
}

.option-card.active {
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  color: white;
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.4);
}

.form-container {
  /* 表单容器样式 */
}

/* 响应式调整 */
@media (max-width: 768px) {
  .card-container {
    padding: 14px;
  }

  .card-title {
    font-size: 14px;
    margin-bottom: 10px;
  }

  .option-card {
    padding: 8px 12px;
    font-size: 13px;
  }

  .card-options {
    gap: 6px;
  }
}

/* Element Plus 组件样式覆盖 */
:deep(.el-input-number) {
  width: 100%;
}

:deep(.el-input-number__increase),
:deep(.el-input-number__decrease) {
  display: none;
}

:deep(.el-button--large) {
  width: 100%;
  max-width: 300px;
}

@media (max-width: 640px) {
  :deep(.el-button--large) {
    width: 100%;
    max-width: 100%;
  }
}
</style>