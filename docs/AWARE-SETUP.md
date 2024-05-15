## Installation instructions

A full deployment can take roughly 30min. A script is coming soon to automate these steps.

### 1. Entra ID App Registrations

#### Frontend app registration

* Select Single-page application (SPA) as platform type, and set the redirect URI to http://localhost:3000
* Select Accounts in this organizational directory only ({YOUR TENANT} only - Single tenant) as supported account types.
* Make a note of the Application (client) ID from the Azure Portal for use in the Deploy Frontend step below.

#### Backend app registration

* Do not set a redirect URI
* Select Accounts in this organizational directory only ({YOUR TENANT} only - Single tenant) as supported account types.
* Make a note of the Application (client) ID from the Azure Portal for use in the Deploy Azure infrastructure step below.
Linking the frontend to the backend

#### Expose an API within the backend app registration

* Select Expose an API from the menu
* Add an Application ID URI
  * This will generate an api:// URI
  * Click Save to store the generated URI
* Add a scope for access_as_user
  * Click Add scope
  * Set Scope name to access_as_user
  * Set Who can consent to Admins and users
  * Set Admin consent display name and User consent display name to Access Chat Copilot as a user
  * Set Admin consent description and User consent description to Allows the accesses to the Chat Copilot web API as a user
* Add the web app frontend as an authorized client application
  * Click Add a client application
  * For Client ID, enter the frontend's application (client) ID
  * Check the checkbox under Authorized scopes
  * Click Add application
* Add permissions to web app frontend to access web api as user
  * Open app registration for web app frontend
  * Go to API Permissions
  * Click Add a permission
  * Select the tab APIs my organization uses
  * Choose the app registration representing the web api backend
  * Select permissions access_as_user
  * Click Add permissions

### 2. Template deployment

* Navigate to [aware.to/tsi/chatcopilot](https://aware.to/tsi/chatcopilot)
* Update enter application details and Azure OpenAI service details

### 3. Azure AI Search index setup

![alt text](aisearch.png)

* Navigate to your Azure AI Search service in the Azure Portal
* Select Indexes
* Select Add Index > Add Index (JSON) and paste the full json files below
* Repeat for each index

```json
{
  "name": "chatmemory",
  "defaultScoringProfile": null,
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": true,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "tags",
      "type": "Collection(Edm.String)",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "payload",
      "type": "Edm.String",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "embedding",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": 1536,
      "vectorSearchProfile": "KMDefaultProfile",
      "synonymMaps": []
    }
  ],
  "scoringProfiles": [],
  "corsOptions": null,
  "suggesters": [],
  "analyzers": [],
  "normalizers": [],
  "tokenizers": [],
  "tokenFilters": [],
  "charFilters": [],
  "encryptionKey": null,
  "similarity": {
    "@odata.type": "#Microsoft.Azure.Search.BM25Similarity",
    "k1": null,
    "b": null
  },
  "semantic": null,
  "vectorSearch": {
    "algorithms": [
      {
        "name": "KMDefaultAlgorithm",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "cosine",
          "m": 4,
          "efConstruction": 400,
          "efSearch": 500
        },
        "exhaustiveKnnParameters": null
      }
    ],
    "profiles": [
      {
        "name": "KMDefaultProfile",
        "algorithm": "KMDefaultAlgorithm",
        "vectorizer": null
      }
    ],
    "vectorizers": []
  }
}
```

```json
{
  "name": "global-documents",
  "defaultScoringProfile": null,
  "fields": [
    {
      "name": "Id",
      "type": "Edm.String",
      "searchable": false,
      "filterable": false,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": true,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "Embedding",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": 1536,
      "vectorSearchProfile": "searchProfile",
      "synonymMaps": []
    },
    {
      "name": "Text",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": true,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "Description",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": true,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "AdditionalMetadata",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": true,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "ExternalSourceName",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": true,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    },
    {
      "name": "IsReference",
      "type": "Edm.Boolean",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": true,
      "key": false,
      "indexAnalyzer": null,
      "searchAnalyzer": null,
      "analyzer": null,
      "normalizer": null,
      "dimensions": null,
      "vectorSearchProfile": null,
      "synonymMaps": []
    }
  ],
  "scoringProfiles": [],
  "corsOptions": null,
  "suggesters": [],
  "analyzers": [],
  "normalizers": [],
  "tokenizers": [],
  "tokenFilters": [],
  "charFilters": [],
  "encryptionKey": null,
  "similarity": {
    "@odata.type": "#Microsoft.Azure.Search.BM25Similarity",
    "k1": null,
    "b": null
  },
  "semantic": null,
  "vectorSearch": {
    "algorithms": [
      {
        "name": "searchAlgorithm",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "cosine",
          "m": 4,
          "efConstruction": 400,
          "efSearch": 500
        },
        "exhaustiveKnnParameters": null
      }
    ],
    "profiles": [
      {
        "name": "searchProfile",
        "algorithm": "searchAlgorithm",
        "vectorizer": null
      }
    ],
    "vectorizers": []
  }
}
```

### 4. Theming, branding & lockdown

* Open the App Service
* Select Settings > Environment Variables
* Click Advanced Edit and paste the following settings below
* Modify the settings as appropriate, make sure to clear the cache after saving

```json
{
  "name": "Frontend__applicationName",
  "value": "Aged Care Copilot"
},
{
  "name": "Frontend__applicationNameVisible",
  "value": "true"
},
{
  "name": "Frontend__copilotName",
  "value": "Aware"
},
{
  "name": "Frontend__documentsTabVisible",
  "value": "true"
},
{
  "name": "Frontend__faviconUrl",
  "value": "https://awaretsi.blob.core.windows.net/assets/aware_favicon.png"
},
{
  "name": "Frontend__globalDocumentsVisible",
  "value": "true"
},
{
  "name": "Frontend__pageLogoUrl",
  "value": "https://awaretsi.blob.core.windows.net/assets/aware_white_on_black.png"
},
{
  "name": "Frontend__pageTitle",
  "value": "Aged Care Copilot"
},
{
  "name": "Frontend__plansTabVisible",
  "value": "false"
},
{
  "name": "Frontend__pluginGalleryVisible",
  "value": "false"
},
{
  "name": "Frontend__primaryColor",
  "value": "#99fcd6"
}
```