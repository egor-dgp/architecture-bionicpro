// src/keycloak.ts
import Keycloak from "keycloak-js";

const keycloak = new Keycloak({
  url: "http://localhost:8080",
  realm: "reports-realm",
  clientId: "reports-frontend",
});

export default keycloak;