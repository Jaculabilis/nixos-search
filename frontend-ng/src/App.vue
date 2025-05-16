<script setup lang="ts">
</script>

<template>
  <main>
    <h1>Search more than <strong>2 packages</strong></h1>

    <form>
      <div style="display: grid; grid-template-columns: auto 8em;">
        <input
          id="search-query-input"
          type="text"
          autofocus
          placeholder="Search for packages"
        />
        <button type="submit">Search</button>
      </div>
      Channel:
      <input type="radio" id="24.11" name="channel" value="24.11" checked />
      <label for="24.11">24.11</label>
      <input type="radio" id="unstable" name="channel" value="unstable" />
      <label for="unstable">Unstable</label>
    </form>
  </main>
</template>

<style scoped>
main h1 {
  font-weight: 400;
}
</style>
