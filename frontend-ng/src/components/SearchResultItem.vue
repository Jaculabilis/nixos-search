<script setup lang="ts">
import { computed } from "vue";
import MaintainerInfo  from "./MaintainerInfo.vue";

const props = defineProps<{
  data: any
}>()

function githubUrl(position: string): string {
  let path = position.replace(":", "#L");
  let branch = "nixos-24.11"; // TODO
  return `https://github.com/NixOS/nixpkgs/blob/${branch}/${path}`
}

const programs = computed(() => {
  return props.data.package_programs.toSorted();
});
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
      <h4>Programs provided:</h4>
      <p>
        <template v-for="(program, index) in programs">
          {{ index > 0 ? " " : "" }}
          <code>
            {{ program }}
          </code>
        </template>
      </p>
      <div>
        <h4>Maintainers</h4>
        <ul>
          <li v-if="data.package_maintainers.length == 0">No maintainers</li>
          <li v-for="maintainer in data.package_maintainers">
            <MaintainerInfo :maintainer="maintainer" />
          </li>
          <li v-if="data.package_maintainers.length > 1">
            <a v-bind:href="`mailto:${data.package_maintainers.map((m: any) => m.email ? m.email : '').join(',')}`">
              &#x2709; Mail to all maintainers
            </a>
          </li>
          <li style="user-select: none;">
            Maintainer GitHub handles:
            <code style="user-select: text;">
              {{ data.package_maintainers.map((m: any) => m ? `@${m.github}` : "").join(" ") }}
            </code>
          </li>
        </ul>
      </div>
      <div v-if="data.package_teams.length > 0">
        <h4>Teams</h4>
        <ul>
          <li v-for="team in data.package_teams">
            {{ team.shortName }}:
            <a
              v-if="team.githubTeams.length > 0"
              v-bind:href="`https://github.com/orgs/NixOS/teams/${team.githubTeams[0]}`"
            >
              @NixOS/{{ team.githubTeams[0] }}
            </a>
            <br />
            <em>{{ team.scope }}</em>
          </li>
        </ul>
      </div>
    </details>
  </li>
</template>

<style scoped>
code {
  background-color: #f7f7f9;
  border: 1px solid #e1e1e8;
  color: #d14;
  padding: 2px 4px;
  white-space: nowrap;
}
</style>
