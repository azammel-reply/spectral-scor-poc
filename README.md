# Spectral POC SCOR

This is a Proof of Concept (POC) for using the **Spectral** linter to secure SCOR's API specifications.
It incorporates standard OpenAPI rules and the **OWASP API Security Top 10** ruleset to detect common security vulnerabilities early in the design phase, ensuring adherence to **Corporate Security Standards**.

---

##  Installation and Usage Guide

Follow this guide to install the necessary tools and run security checks on this POC.

###  1. Prerequisites: Verify Node.js and npm

Spectral is installed via npm, so Node.js is required.

Check if you already have them:
```bash
node -v
npm -v
```

> **Note**: If you don't have them or your version is too old (Node < 14), proceed to the next step.

###  2. Install Node.js (if necessary)

**Recommended option (Mac/Linux with Homebrew):**
```bash
brew install node
```

Verify installation:
```bash
node -v
npm -v
```

###  3. Install Spectral

#### A. Global Installation (For usage everywhere)
Convenient for accessing the `spectral` command from any folder.
```bash
npm install -g @stoplight/spectral-cli
```

Verify it works:
```bash
spectral --version
```

#### B. Project Installation (Already configured)
This project already includes Spectral in its dependencies (`package.json`).
Simply install the project dependencies:
```bash
npm install
```
*This installs Spectral only in the `node_modules` folder of this project.*

###  4. Verify Spectral works

To test quickly, you can create a small test file:
```bash
echo "openapi: 3.0.0" > test.yaml
```

Run Spectral on it:
```bash
spectral lint test.yaml
```
*(If you didn't install globally, use `npx spectral lint test.yaml`)*

> 👉 You should see warnings or errors: this means Spectral is working.

---

## 🚀 Using the POC

This project contains two API specifications for demonstration:
1.  **`specs/customer-api-v1.yaml`**: A secure spec (should pass without errors).
2.  **`specs/customer-api-v1-insecure.yaml`**: A vulnerable spec (should trigger OWASP errors).

### Run Security Checks

We use `npx` to run the checked-in version of Spectral.

**Test the VALID spec:**
```bash
npx spectral lint specs/customer-api-v1.yaml --ruleset owasp23-ruleset.spectral.yml
```
> *Expected Result: No errors.*

**Test the INSECURE spec:**
```bash
npx spectral lint specs/customer-api-v1-insecure.yaml --ruleset owasp23-ruleset.spectral.yml
```
> *Expected Result: Multiple OWASP security errors.*

### Using Rulesets

You can tell Spectral to use a specific ruleset file with the `-r` or `--ruleset` option.

**Example with a local ruleset (this project):**
```bash
npx spectral lint specs/customer-api-v1.yaml -r owasp23-ruleset.spectral.yml
```

**Example with the official OWASP ruleset (online):**
```bash
npx spectral lint specs/customer-api-v1.yaml -r https://unpkg.com/@stoplight/spectral-owasp-ruleset/dist/ruleset.js
```

---

## 🛡️ What is being checked? (Security Rules)

We are using a custom configuration `owasp23-ruleset.spectral.yml` that combines:

1.  **`spectral:oas`**: Standard validations involving the OpenAPI Specification (OAS) structure (completeness, syntax).
2.  **OWASP API Security Ruleset (2023)**: Specific security checks mapped to the OWASP API Security Top 10 vulnerabilities.

### Key OWASP Rules Enforced
The following rules are actively checked in this POC:

| OWASP Category                                     | Rule Description                                                                                      | Why it matters                                                                 |
| :------------------------------------------------- | :---------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------- |
| **API1:2023**<br>Broken Object Level Auth          | **Random IDs**: Checks that resource IDs uses random strings (UUIDs) instead of predictable integers. | Prevents attackers from guessing IDs to access other users' data.              |
| **API2:2023**<br>Broken Authentication             | **No Basic Auth**: Blocks usage of HTTP Basic Authentication.                                         | Basic Auth credentials are easily intercepted and leaked.                      |
|                                                    | **No API Keys in URL**: Ensures API keys are not passed in query parameters or path.                  | URLs are often logged, exposing keys to anyone with log access.                |
|                                                    | **Short-lived Tokens**: Checks if OAuth2 flows support refresh tokens.                                | Access tokens should expire quickly to limit the window of an attack.          |
| **API3:2023**<br>Broken Object Prop. Auth          | **No Unknown Properties**: Enforces `additionalProperties: false` or constrained properties.          | Prevents "Mass Assignment" attacks where attackers inject unauthorized fields. |
| **API4:2023**<br>Unrestricted Resource Consumption | **Rate Limiting**: Checks for headers like `RateLimit-Limit` or `X-RateLimit-Limit`.                  | Prevents Denial of Service (DoS) and brute force attacks.                      |
|                                                    | **Data Limits**: Enforces `maxLength` for strings and `maxItems` for arrays.                          | Prevents huge payloads from crashing the server or exhausting memory.          |
| **API8:2023**<br>Security Misconfiguration         | **CORS**: Checks for Access-Control-Allow-Origin headers.                                             | Prevents unauthorized cross-origin requests.                                   |
|                                                    | **No HTTP**: Forces `https` or `wss` schemes.                                                         | Ensures all traffic is encrypted in transit.                                   |
|                                                    | **Error Validation**: Ensures 4xx/5xx error responses are defined.                                    | Prevents leaking sensitive implementation details in stack traces.             |
| **API9:2023**<br>Improper Inventory                | **Inventory Info**: Checks for `x-internal` flags and environment descriptions (prod/stage).          | Helps distinguish public vs private APIs and proper environment usage.         |

---

##  Example Output

When running the linter against `specs/customer-api-v1-insecure.yaml`, you will see output similar to this:

```text
/path/to/specs/customer-api-v1-insecure.yaml
  16:16  warning  owasp:api2:2023-no-http-basic             Security scheme uses HTTP Basic. Use a more secure authentication method...
  24:21  warning  owasp:api3:2023-no-additionalProperties   If the additionalProperties keyword is used it must be set to false.
  45:15  warning  owasp:api4:2023-string-limit              Schema of type string must specify maxLength, enum, or const.
  52:10  warning  owasp:api8:2023-no-server-http            Server URLs must not use http://. Use https:// or wss:// instead.
```

---

##  CI/CD Integration Examples

Spectral is designed to run in your CI/CD pipelines to block insecure specs from being deployed.

### GitHub Actions
```yaml
name: Spectral Linting
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install
      - run: npx spectral lint specs/*.yaml --ruleset owasp23-ruleset.spectral.yml
```

### GitLab CI
```yaml
spectral_lint:
  image: node:latest
  stage: test
  script:
    - npm install
    - npx spectral lint specs/*.yaml --ruleset owasp23-ruleset.spectral.yml
  allow_failure: true
```

