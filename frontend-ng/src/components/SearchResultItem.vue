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
  <li class="search-result-item">
    <span><a href="">{{ data.package_attr_name }}</a></span>
    <div class="description">{{ data.package_description }}</div>
    <ul>
      <li>Name: {{ data.package_pname }}</li>
      <li v-if="data.package_pversion">Version: <strong>{{ data.package_pversion }}</strong></li>
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
      <!-- TODO install instructions -->
      <!-- <h4>Install</h4>
      <p>todo</p> -->
      <h4>Programs provided</h4>
      <p v-if="programs.length > 0">
        <template v-for="(program, index) in programs">
          {{ index > 0 ? " " : "" }}
          <code>
            {{ program }}
          </code>
        </template>
      </p>
      <p v-else>This package provides no programs.</p>
      <div>
        <h4>Maintainers</h4>
        <ul v-if="data.package_maintainers.length > 0">
          <li v-for="maintainer in data.package_maintainers">
            <MaintainerInfo :maintainer="maintainer" />
          </li>
          <li v-if="data.package_maintainers.length > 1">
            <a v-bind:href="`mailto:${data.package_maintainers.map((m: any) => m.email ? m.email : '').join(',')}`">
              &#x2709; Mail to all maintainers
            </a>
          </li>
          <li style="user-select: none;" v-if="data.package_maintainers.length > 1">
            Maintainer GitHub handles:
            <code style="user-select: text;">
              {{ data.package_maintainers.map((m: any) => m ? `@${m.github}` : "").join(" ") }}
            </code>
          </li>
        </ul>
        <p v-else>This package has no maintainers. If you find it useful, please consider becoming a maintainer!</p>
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
      <!-- TODO filter to the "big four" (or hide the others?) and link to hydra -->
      <!-- <div>
        <h4>Platforms</h4>
      </div> -->
    </details>
  </li>
</template>

<style scoped>
.search-result-item {
  margin-bottom: 30px;
  padding-bottom: 30px;
  border-bottom: 1px solid gray;
}
.search-result-item .description {
  font-size: 1.2em;
}
.search-result-item > ul {
  list-style: none;
  padding: 0;
  text-align: left;
}
.search-result-item > ul > li {
  display: inline-block;
  margin-right: 1em;
  color: #666;
}
.search-result-item > details > summary {
  margin-top: 10px;
  text-align: center;
  cursor: pointer;
  user-select: none;
}
.search-result-item > details > summary::marker {
  content: "\1F4C1  "
}
.search-result-item > details[open] > summary::marker {
  content: "\1F4C2  "
}

code {
  background-color: #f7f7f9;
  border: 1px solid #e1e1e8;
  color: #d14;
  padding: 2px 4px;
  white-space: nowrap;
}
</style>
