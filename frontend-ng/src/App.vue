<script setup lang="ts">
import { ref, type Ref } from 'vue';

const query = ref('');
const channel = ref('24.11');

const queries: Ref<string[], string[]> = ref([])
function submit() {
  queries.value.push(query.value);
}
</script>

<template>
  <main>
    <h1>Search more than <strong>2 packages</strong></h1>

    <form @submit.prevent="submit">
      <div style="display: grid; grid-template-columns: auto 8em;">
        <input
          id="search-query-input"
          type="text"
          autofocus
          placeholder="Search for packages"
          v-model="query"
        />
        <button type="submit">Search</button>
      </div>
      Channel:
      <input type="radio" id="24.11" value="24.11" v-model="channel" />
      <label for="24.11">24.11</label>
      <input type="radio" id="unstable" value="unstable" v-model="channel" />
      <label for="unstable">Unstable</label>
    </form>
    <p>Current query: {{ query }}</p>
    <p>Current channel: {{ channel }}</p>
    <p>Queries: {{ queries }}</p>
  </main>
</template>

<style scoped>
main h1 {
  font-weight: 400;
}
</style>
