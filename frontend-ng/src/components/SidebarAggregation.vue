<script setup lang="ts">
const props = defineProps<{
  title: string,
  agg: {
    buckets: [
      {
        key: string,
        doc_count: number,
      }
    ],
  },
}>()
</script>

<template>
  <li v-if="agg.buckets.length > 0">
    <ul class="sidebar-aggregation">
      <li class="sidebar-header">{{ props.title }}</li>
      <li v-for="bucket in agg.buckets">
        <a style="display: grid; grid-template-columns: auto max-content;">
          <span>
            {{ bucket.key }}
          </span>
          <span style="text-align: right;">
            {{ bucket.doc_count }}
          </span>
        </a>
      </li>
    </ul>
  </li>
</template>

<style scoped>
.sidebar-aggregation {
  list-style: none;
  padding: 0;
}
.sidebar-header {
  font-size: 1.2em;
  font-weight: 700;
  margin-bottom: .5em;
}
</style>
