<script setup lang="ts">
import { ref, type Ref } from 'vue';
import SearchResultList from './components/SearchResultList.vue';

const query = ref('');
const channel = ref('24.11');

const queries: Ref<string[], string[]> = ref([])
const lastResponse = ref('');
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
  });
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
    <p>Last results:</p>
    <SearchResultList :dataList="lastResults" />
    <pre>Last response: {{ lastResponse }}</pre>
  </main>
</template>

<style scoped>
main h1 {
  font-weight: 400;
}
</style>
