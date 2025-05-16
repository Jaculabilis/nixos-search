<script setup lang="ts">
import { ref, type Ref } from 'vue';
import SearchResultList from './components/SearchResultList.vue';

const query = ref('');

const channels: string[] = JSON.parse(import.meta.env.VITE_NIXOS_CHANNELS || '["unstable"]');
const channel = ref(channels[channels.length - 1]);

const queries: Ref<string[], string[]> = ref([])
const lastResponse = ref('');
const waiting = ref(false);
const lastResults = ref([]);
function submit() {
  queries.value.push(query.value);

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
  const url = "https://search.nixos.org/backend/latest-43-nixos-24.11/_search";
  waiting.value = true;
  fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Basic YVdWU0FMWHBadjpYOGdQSG56TDUyd0ZFZWt1eHNmUTljU2g=',
    },
    body: JSON.stringify(queryPayload)
  }).then(response => {
    response.json().then(data => {
      lastResponse.value = JSON.stringify(data, null, 2);
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
        <button class="btn" type="submit">Search</button>
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
    <!-- Currently this breaks after the first query. idk why yet. -->
    <img id="spinner" v-if="waiting" class="logo" src="./assets/logo-black.svg" />
    <p>Current query: {{ query }}{{ waiting ? " (waiting)" : "" }}</p>
    <p>Current channel: {{ channel }}</p>
    <p>Queries: {{ queries }}</p>
    <p>Last results:</p>
    <SearchResultList :dataList="lastResults" />
    <pre>Last response: {{ lastResponse }}</pre>
  </main>
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

@keyframes rotation {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(359deg);
  }
}
#spinner {
  width: 3em;
  height: 3em;
  animation: rotation 2s infinite linear;
}
</style>
