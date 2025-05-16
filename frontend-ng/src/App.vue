<script setup lang="ts">
import { ref, type Ref } from 'vue';
import SearchResultList from './components/SearchResultList.vue';
import SidebarAggregation from './components/SidebarAggregation.vue';

const isDev = import.meta.env.DEV;

// TODO the state here should be persisted to the query parameters so the page refreshes to the same search

const query = ref('');

const channels: string[] = JSON.parse(import.meta.env.VITE_NIXOS_CHANNELS || '["unstable"]');
const channel = ref(channels[channels.length - 1]);

const queries: Ref<string[], string[]> = ref([])
const lastResponse: Ref<any, any> = ref({});
const waiting = ref(false);
const lastResults = ref([]);
function submit() {
  queries.value.push(query.value);

  // TODO this needs to be refactored elsewhere and support filters
  const queryPayload = {
    "from":0,
    "size":50,
    "sort": [
      {
        "_score": "desc",
        "package_attr_name": "desc",
        "package_pversion": "desc"
      }
    ],
    "aggs": {
      "package_attr_set": {
        "terms": {
          "field": "package_attr_set",
          "size":20
        }
      },
      "package_license_set": {
        "terms": {
          "field": "package_license_set",
          "size":20
        }
      },
      "package_maintainers_set": {
        "terms": {
          "field": "package_maintainers_set",
          "size":20
        }
      },
      "package_teams_set": {
        "terms": {
          "field": "package_teams_set",
          "size":20
        }
      },
      "package_platforms": {
        "terms": {
          "field": "package_platforms",
          "size":20
        }
      },
      "all": {
        "global": {},
        "aggregations": {
          "package_attr_set": {
            "terms": {
              "field": "package_attr_set",
              "size":20
            }
          },
          "package_license_set": {
            "terms": {
              "field": "package_license_set",
              "size":20
            }
          },
          "package_maintainers_set": {
            "terms": {
              "field": "package_maintainers_set",
              "size":20
            }
          },
          "package_teams_set": {
            "terms": {
              "field": "package_teams_set",
              "size":20
            }
          },
          "package_platforms":{
            "terms":{
              "field":"package_platforms",
              "size":20
            }
          }
        }
      }
    },
    "query":{
      "bool":{
        "filter":[
          {
            "term":{
              "type":{
                "value":"package",
                "_name":"filter_packages"
              }
            }
          },
          {
            "bool":{
              "must":[
                {
                  "bool":{
                    "should":[]
                  }
                },
                {
                  "bool":{
                    "should":[]
                  }
                },
                {
                  "bool":{
                    "should":[]
                  }
                },
                {
                  "bool":{
                    "should":[]
                  }
                },
                {
                  "bool":{
                    "should":[]
                  }
                }
              ]
            }
          }
        ],
        "must":[
          {
            "dis_max":{
              "tie_breaker":0.7,
              "queries":[
                {
                  "multi_match":{
                    "type":"cross_fields",
                    "query":query.value,
                    "analyzer":"whitespace",
                    "auto_generate_synonyms_phrase_query":false,
                    "operator":"and",
                    "_name":"multi_match_" + query.value,
                    "fields":[
                      "package_attr_name^9",
                      "package_attr_name.*^5.3999999999999995",
                      "package_programs^9",
                      "package_programs.*^5.3999999999999995",
                      "package_pname^6",
                      "package_pname.*^3.5999999999999996",
                      "package_description^1.3",
                      "package_description.*^0.78",
                      "package_longDescription^1",
                      "package_longDescription.*^0.6",
                      "flake_name^0.5",
                      "flake_name.*^0.3"
                    ]
                  }
                },
                {
                  "wildcard":{
                    "package_attr_name":{
                      "value":"*"+query.value+"*",
                      "case_insensitive":true
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  };
  // TODO derive this from the current channel, or configs perhaps
  const url = "https://search.nixos.org/backend/latest-43-nixos-24.11/_search";
  waiting.value = true;
  fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      // TODO this should come from config
      'Authorization': 'Basic YVdWU0FMWHBadjpYOGdQSG56TDUyd0ZFZWt1eHNmUTljU2g=',
    },
    body: JSON.stringify(queryPayload)
  }).then(response => {
    response.json().then(data => {
      lastResponse.value = data;
      lastResults.value = data.hits.hits.map((hit: any) => {
        return hit._source;
      });
    })
  }).finally(() => {
    waiting.value = false;
  });
}
</script>

<template>
  <header>
    <a href="https://nixos.org"><img alt="Nix" class="logo" src="./assets/logo-default.svg" /></a>
    <div>
      <ul>
        <!-- TODO these need to change query options without reloading the page -->
        <li><a href="https://nixos.org">Back to nixos.org</a></li>
        <li class="active"><a href="#">Packages</a></li>
        <li><a href="#">NixOS options</a></li>
        <li><a href="#">Flakes <sup>Experimental</sup></a></li>
      </ul>
    </div>
  </header>

  <main>
    <h1>Search more than <strong>120 000 packages</strong></h1>

    <form @submit.prevent="submit">
      <div class="search">
        <input
          id="search-query-input"
          type="text"
          autofocus
          placeholder="Search for packages"
          v-model="query"
        />
        <button class="btn" type="submit">
          {{ !waiting ? "Search" : "" }}
          <img id="spinner" v-if="waiting" class="logo" src="./assets/logo-black.svg" />
        </button>
      </div>
      <div class="channel">
        <h2>Channel: </h2>
        <div class="channel-buttons">
          <template v-for="chan in channels">
            <input type="radio" :id="chan" :value="chan" v-model="channel" />
            <label class="btn" :for="chan">{{ chan }}</label>
          </template>
        </div>
      </div>
    </form>

    <div class="search-results">
      <ul class="search-sidebar" v-if="lastResponse.aggregations">
        <SidebarAggregation title="Package sets" :agg="lastResponse.aggregations.package_attr_set" />
        <SidebarAggregation title="Licenses" :agg="lastResponse.aggregations.package_license_set" />
        <SidebarAggregation title="Maintainers" :agg="lastResponse.aggregations.package_maintainers_set" />
        <SidebarAggregation title="Teams" :agg="lastResponse.aggregations.package_teams_set" />
        <SidebarAggregation title="Platforms" :agg="lastResponse.aggregations.package_platforms" />
      </ul>
      <div>
        <SearchResultList :dataList="lastResults" />
      </div>
    </div>
  </main>

  <footer>
    <div>
      <span>Please help us improve search.nixos.org by <a href="#">reporting issues</a>.</span>
    </div>
    <div>
      <span>❤️  </span>
      <span>Elasticsearch instance graciously provided by </span>
      <a href="https://bonsai.io">Bonsai</a>
      <span>. Thank you! ❤️ </span>
    </div>
  </footer>

  <details v-if="isDev" open>
    <summary>state</summary>
    <p>Current query: {{ query }}{{ waiting ? " (waiting)" : "" }}</p>
    <p>Current channel: {{ channel }}</p>
    <p>Queries: {{ queries }}</p>
    <details>
      <summary>Last results:</summary>
      <pre style="font-size: 8px; line-height: normal; white-space: pre-wrap;">{{ JSON.stringify(lastResponse, null, 2) }}</pre>
    </details>
    <details open>
      <summary>$.hits.hits</summary>
      <pre style="font-size: 8px; line-height: normal; white-space: pre-wrap;" v-if="lastResponse.hits">{{ lastResponse.hits.hits }}</pre>
    </details>
    <details open>
      <summary>$.aggregations</summary>
      <pre style="font-size: 8px; line-height: normal; white-space: pre-wrap;">{{ lastResponse.aggregations }}</pre>
    </details>
  </details>
</template>

<style scoped>
header {
  display: block;
  min-height: 40px;
  padding-left: 20px;
  padding-right: 20px;
  border: 1px solid #d4d4d4;

  background-color: #fafafa;
  background-image: linear-gradient(180deg,#fff,#f2f2f2);
  background-repeat: repeat-x;

  border-radius: 0;
  border-width: 0 0 1px;

  -webkit-box-shadow: 0 1px 10px rgba(0,0,0,.1);
  -moz-box-shadow: 0 1px 10px rgba(0,0,0,.1);
  box-shadow: 0 1px 10px rgba(0,0,0,.1);

  overflow: visible;
  margin-bottom: 0;
  position: static;
  border-width: 0 0 1px;
  overflow: visible;
}
header::after {
  clear: both;
}
header img.logo {
  height: 2.7em;
  float: left;
}
header ul {
  display: block;
  float:left;
  left: 0;
  margin: 0 10px 0 0;
  position: relative;
  list-style: none;
}
header li {
  float: left;
  line-height: 20px;
}
header li a {
  display: block;
  padding: 10px 15px;
  text-decoration: none;
  color: #777;
}
header li a:focus, header li a:hover {
  color: #333;
}
header li.active a {
  background-color: #e5e5e5;
  color: #555;
  box-shadow: inset 0 3px 8px rgba(0,0,0,.125);
}
header sup {
  top: -.5em;
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
  
  color: #fff;
  background-color: #007dbb;
  font-weight: 700;
  padding: 2px 4px;
  text-shadow: 0 -1px 0 rgba(0, 0, 0, .25);
  border-radius: 3px;
}

main {
  margin: 0 20px;
}
main h1 {
  font-size: 2.3em;
  font-weight: 400;
}
main h1::before {
  content: "\2315";
  display: inline-block;
  font-family: monospace;
  font-size: 2em;
  margin-right: .2em;
  transform: translateY(.15em) scaleX(-1);
}
main .btn {
  cursor: pointer;
  border: 1px solid #ccc;
  background-image: -moz-linear-gradient(top,#fff,#e6e6e6);
  background-image: -webkit-gradient(linear,0 0,0 100%,from(#fff),to(#e6e6e6));
  background-image: -webkit-linear-gradient(top,#fff,#e6e6e6);
  background-image: -o-linear-gradient(top,#fff,#e6e6e6);
  background-image: linear-gradient(180deg,#fff,#e6e6e6);
  background-repeat: repeat-x;
  padding: 4px 12px;
  text-align: center;
  text-shadow: 0 1px 1px hsla(0,0%,100%,.75);
}
main .search {
  display: grid;
  grid-template-columns: auto 8em;
}
main .search input {
  font-size: 18px;
  height: 40px;
}
main .search button {
  font-size: 24px;
}
main .channel {
  vertical-align: middle;
  margin-top: 10px;
}
main .channel h2 {
  display: inline;
  font-size: 1.2em;
  margin-left: .2em;
  vertical-align: middle;
}
main .channel-buttons {
  display: inline-block;
  vertical-align: middle;
}
main .channel-buttons input[type="radio"] {
  display: none;
}
main .channel-buttons input[type="radio"] + label {
  display: inline-block;
}
main .channel-buttons input[type="radio"]:checked + label {
  background-image: none;
  box-shadow: inset 0 2px 4px rgba(0,0,0,.15),0 1px 2px rgba(0,0,0,.05);
  background: #e6e6e6;
}

.search-sidebar {
  list-style: none;
  width: 25em;
}
.search-sidebar > li {
  border: 1px solid #ccc;
  border-radius: 4px;
  margin-bottom: 1em;
  padding: 1em;
}
.search-sidebar {
  padding: 0;
}
.sidebar-header {
  font-size: 1.2em;
  font-weight: 700;
  margin-bottom: .5em;
}
main .search-results {
  display: flex;
  flex-direction: row;
}

footer {
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  height: 4rem;
  width: 100%;
  text-align: center;
  font-size: 14px;
  line-height: 20px;
}

@keyframes rotation {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(359deg);
  }
}
#spinner {
  width: 1.5em;
  height: 1.5em;
  animation: rotation 2s infinite linear;
  vertical-align: middle;
}
</style>
