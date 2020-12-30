___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "URL Parser",
  "description": "With this variable template, input any complete URL and select which components of the URL you\u0027d like returned.",
  "containerContexts": [
    "WEB"
  ], 
  "categories": ["UTILITY"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "inputURL",
    "displayName": "Input a URL or URL Variable",
    "simpleValueType": true,
    "help": "In this field, input a full URL or a URL variable, from which you\u0027d like to extract URL components. For instance, \u003cstrong\u003e{{Click URL}}\u003c/strong\u003e or \u003cstrong\u003e{{Page URL}}\u003c/strong\u003e",
    "valueHint": "e.g. https://iihnordic.com/services/"
  },
  {
    "type": "SELECT",
    "name": "returnComponent",
    "displayName": "Return URL Component",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "protocol",
        "displayValue": "Protocol"
      },
      {
        "value": "hostname",
        "displayValue": "Full Hostname"
      },
      {
        "value": "rootHostname",
        "displayValue": "Root Hostname (Hostname without subdomains)"
      },
      {
        "value": "uri",
        "displayValue": "Page Path / URI"
      },
      {
        "value": "queryParam",
        "displayValue": "Query Parameter"
      },
      {
        "value": "fragment",
        "displayValue": "Fragment"
      },
      {
        "value": "baseURL",
        "displayValue": "Base URL (URL without query parameters and fragments)"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "CHECKBOX",
    "name": "returnUriIndex",
    "checkboxText": "Return a certain Page Path level",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnComponent",
        "paramValue": "uri",
        "type": "EQUALS"
      }
    ],
    "help": "Check this box if you\u0027d like to return a certain part/level of the input Page Path, based on index. Leave unchecked to return the full Page Path."
  },
  {
    "type": "CHECKBOX",
    "name": "inverseIndex",
    "checkboxText": "Use Inverted Indexing",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnUriIndex",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "Check this box if you\u0027d like to use inversed indexing for the query path. If this box is checked, the input \u003cstrong\u003e1\u003c/strong\u003e returns the last page path level, \u003cstrong\u003e2\u003c/strong\u003e returns the second last, etc."
  },
  {
    "type": "TEXT",
    "name": "uriIndex",
    "displayName": "Page Path Index",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnUriIndex",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "POSITIVE_NUMBER"
      }
    ],
    "help": "In this field, input the index of the page path level you would like to return (indexing starts at \u003cstrong\u003e1\u003c/strong\u003e). Check \u0027Use Inverted Indexing\u0027 to invert indexing.",
    "valueHint": "e.g. 1, 2 or 3 etc."
  },
  {
    "type": "TEXT",
    "name": "returnQueryKey",
    "displayName": "Input the Query Parameter key",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "returnComponent",
        "paramValue": "queryParam",
        "type": "EQUALS"
      }
    ],
    "help": "In this text field, input the key to the URL query parameter whose value you\u0027d like to return",
    "valueHint": "e.g. apikey",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "uriDecode",
    "checkboxText": "URI decode",
    "simpleValueType": true,
    "help": "Check this box if you\u0027d like to URI Decode the output.",
    "defaultValue": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Enter your template code here.
const decode = require("decodeUriComponent");
// const print = require("logToConsole");
// const makeNumber = require("makeNumber");

// Pre-checks and work
const url = data.inputURL;

const urlIsValid = url.indexOf("http") === 0;
if (!urlIsValid){ return undefined; }

// Initial breakdown of the URL

const urlComponents = (() => {
  const comps = {};
  
  const fragmentIndex = url.indexOf("#") === -1 ? url.length : url.indexOf("#");
  const queriesIndex = url.indexOf("?") === -1 ? fragmentIndex : url.indexOf("?");
  
  comps.baseURL = url.slice(0, queriesIndex);
  comps.queries = url.slice(queriesIndex, fragmentIndex);
  comps.fragment = url.slice(fragmentIndex, url.length);
  
  return comps;
})();

const parsedURL = {};
parsedURL.protocol = urlComponents.baseURL.slice(0, urlComponents.baseURL.indexOf(":")).toUpperCase();
parsedURL.hostname = urlComponents.baseURL.split("/").filter(x => x)[1];
parsedURL.rootHostname = parsedURL.hostname.split(".").slice(parsedURL.hostname.split(".").length - 2).join(".");
parsedURL.uri = uri(data.uriIndex, data.inverseIndex);
parsedURL.queryParam = data.returnObjectified ? objectify(urlComponents.queries) : objectify(urlComponents.queries)[data.returnQueryKey];
parsedURL.fragment = urlComponents.fragment.slice(1);
parsedURL.baseURL = urlComponents.baseURL;

// Variable myst return a value
return parsedURL[data.returnComponent];

// Helper functions
function objectify(keyValuePairs) {
  return keyValuePairs.slice(1).split("&").reduce((agg, current) => {
    const pair = current.split("=");
    agg[pair[0]] = pair[1];
    return agg;
  }, {});
}

function uri(findByIndex, inverted) {
  const uriSections = urlComponents.baseURL.split("/").filter(x => x).slice(2);
  const index = inverted === true ? (uriSections.length - findByIndex) : (findByIndex - 1);
  
  return data.returnUriIndex ? uriSections[index] : ("/" + uriSections.join("/") + "/");
}


___TESTS___

scenarios: []


___NOTES___

Created on 04/12/2019, 10:45:23


