<script setup lang="ts">
defineProps<{
  data: any
}>()

function githubUrl(position: string): string {
  let path = position.replace(":", "#L");
  let branch = "nixos-24.11"; // TODO
  return `https://github.com/NixOS/nixpkgs/blob/${branch}/${path}`
}

</script>

<template>
  <li>
    <span><a href="">{{ data.package_attr_name }}</a></span>
    <div>{{ data.package_attr_description }}</div>
    <ul>
      <li>Name: {{ data.package_pname }}</li>
      <li v-if="data.package_pversion">Version: {{ data.package_pversion }}</li>
      <li v-if="data.package_homepage.length > 0"><a v-bind:href="data.package_homepage">&#x1f310; Homepage</a></li>
      <li><a v-bind:href="githubUrl(data.package_position)">&#x1F4E6; Source</a></li>
      <li v-if="data.package_license.length > 0">
        {{ data.package_license.length == 1 ? "License" : "Licenses" }}:
        <template v-for="(license, index) in data.package_license">
          {{ index > 0 ? " ▪ " : "" }}
          <a v-bind:href="license.url">
            {{ license.fullName }}
          </a>
        </template>
      </li>
    </ul>
    <details>
      <summary>Package details</summary>
      <p v-html="data.package_longDescription"></p>
    </details>
  </li>
</template>

<style scoped>
</style>
