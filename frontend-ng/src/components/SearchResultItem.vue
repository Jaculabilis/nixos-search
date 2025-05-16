<script setup lang="ts">
defineProps<{
  data: any
}>()
</script>

<template>
  <li>
    <span><a href="">{{ data.package_attr_name }}</a></span>
    <div>{{ data.package_attr_description }}</div>
    <ul>
      <li>Name: {{ data.package_pname }}</li>
      <li>Version: {{ data.package_pversion }}</li>
      <li><a href="">Homepage</a></li>
      <li><a href="">Source</a></li>
      <li>License: <a v-bind:href="data.package_license[0].url">{{ data.package_license[0].fullName }}</a></li>
    </ul>
    <details>
      <summary>Package details</summary>
      <p v-html="data.package_longDescription"></p>
    </details>
  </li>
</template>

<style scoped>
</style>
