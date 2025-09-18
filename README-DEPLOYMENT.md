# IMA-APP: SAP Cloud Foundry Deployment Guide

## Overview
This guide walks you through deploying the IMA Material Management System to SAP Business Technology Platform (BTP) Cloud Foundry environment with HANA Cloud database.

## Prerequisites

### Software Requirements
- [Node.js](https://nodejs.org/) (v20 or higher)
- [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
- [MTA Build Tool (MBT)](https://www.npmjs.com/package/mbt): `npm install -g mbt`
- [SAP CDS CLI](https://cap.cloud.sap/docs/get-started/installation): `npm install -g @sap/cds-dk`

### SAP BTP Requirements
- SAP BTP Global Account with Cloud Foundry Environment
- SAP HANA Cloud Instance
- Subaccount with the following entitlements:
  - SAP HANA Schemas & HDI Containers
  - SAP XSUAA Service
  - SAP HTML5 Application Repository
  - SAP Destination Service

## Deployment Steps

### Step 1: Prepare Your Environment

1. **Clone and setup the project:**
   ```bash
   cd ima-app
   npm install
   ```

2. **Login to Cloud Foundry:**
   ```bash
   cf login -a https://api.cf.[region].hana.ondemand.com
   ```

3. **Target your org and space:**
   ```bash
   cf target -o [your-org] -s [your-space]
   ```

### Step 2: Setup HANA Cloud Services

1. **Create HANA HDI Container service:**
   ```bash
   cf create-service hana hdi-shared ima-app-db
   ```

2. **Create XSUAA service:**
   ```bash
   cf create-service xsuaa application ima-app-xsuaa -c xs-security.json
   ```

3. **Create Destination service:**
   ```bash
   cf create-service destination lite ima-app-destination-service
   ```

4. **Create HTML5 Repository service:**
   ```bash
   cf create-service html5-apps-repo app-host ima-app-html5-repo-host
   ```

### Step 3: Build and Deploy

1. **Build the MTA archive:**
   ```bash
   chmod +x scripts/build-mta.sh
   ./scripts/build-mta.sh
   ```
   
   Or manually:
   ```bash
   mbt build
   ```

2. **Deploy to Cloud Foundry:**
   ```bash
   chmod +x scripts/deploy.sh
   ./scripts/deploy.sh
   ```
   
   Or manually:
   ```bash
   cf deploy mta_archives/ima-app_1.0.0.mtar
   ```

### Step 4: Post-Deployment Configuration

1. **Verify deployment:**
   ```bash
   cf apps
   cf services
   ```

2. **Access the application:**
   - Find your app URL: `cf app ima-app-srv`
   - Access the Fiori Launchpad at: `https://[your-app-url]/`

3. **Configure role collections in BTP Cockpit:**
   - Navigate to Security → Role Collections
   - Create role collections: `IMA_Requester`, `IMA_Approver`, `IMA_Analyst`
   - Assign roles and users accordingly

## Configuration Files

### Key Files Created/Modified:
- `mta.yaml` - Multi-Target Application descriptor
- `manifest.yml` - Cloud Foundry deployment manifest
- `xs-security.json` - XSUAA security configuration
- `package.json` - Updated with HANA dependencies
- `.cdsrc.json` - CAP runtime configuration
- Database schema updated for HANA compatibility

## Environment-Specific Configurations

### Development Environment
- Uses SQLite in-memory database
- Mock authentication
- CORS enabled for localhost

### Production Environment
- HANA Cloud database
- XSUAA authentication
- Secure CORS policy

## Troubleshooting

### Common Issues:

1. **MTA Build Fails:**
   ```bash
   # Clean and rebuild
   rm -rf gen/ mta_archives/
   npm install
   mbt build
   ```

2. **HANA Connection Issues:**
   ```bash
   # Check service binding
   cf env ima-app-srv
   # Restart application
   cf restart ima-app-srv
   ```

3. **Authentication Problems:**
   ```bash
   # Check XSUAA service
   cf service ima-app-xsuaa
   # Verify xs-security.json configuration
   ```

4. **App Won't Start:**
   ```bash
   # Check logs
   cf logs ima-app-srv --recent
   # Check health endpoint
   curl https://[your-app-url]/health
   ```

## Database Migration

Your existing SQLite data has been preserved and will be migrated to HANA during deployment. The data model has been enhanced with:
- UUID primary keys
- Proper field lengths and constraints
- Audit fields (createdAt, createdBy, modifiedAt, modifiedBy)
- New fields: requestPriority, approverComments

## Security

The application implements:
- XSUAA-based authentication
- Role-based authorization (Requester, Approver, IMA Analyst)
- Secure API endpoints
- Audit logging

## Monitoring

Monitor your application using:
- CF CLI: `cf logs ima-app-srv`
- BTP Cockpit: Application Logging service
- Custom health endpoint: `/health`

## Support

For issues related to:
- **CAP Framework:** [SAP CAP Documentation](https://cap.cloud.sap/docs/)
- **Cloud Foundry:** [CF Documentation](https://docs.cloudfoundry.org/)
- **SAP BTP:** [SAP Help Portal](https://help.sap.com/products/BTP)

---

**Note:** Make sure all prerequisites are met and you have the necessary permissions in your BTP account before starting the deployment process.
