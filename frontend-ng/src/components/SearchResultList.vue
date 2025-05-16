<script setup lang="ts">
import SearchResultItem from './SearchResultItem.vue'

defineProps<{
  dataList: any
}>()
</script>

<template>
  <ul>
    <template v-for="(data, index) in dataList" :key="index">
      <li>
        <SearchResultItem :data="data" />
      </li>
    </template>
  </ul>
</template>

<style scoped>
ul {
  list-style: none;
}
</style>
