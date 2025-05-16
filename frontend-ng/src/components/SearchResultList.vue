<script setup lang="ts">
import SearchResultItem from './SearchResultItem.vue'

defineProps<{
  dataList: any
}>()
</script>

<template>
  <ul>
    <li v-for="(data, index) in dataList" :key="index">
      <SearchResultItem :data="data" />
    </li>
  </ul>
</template>

<style scoped>
</style>
