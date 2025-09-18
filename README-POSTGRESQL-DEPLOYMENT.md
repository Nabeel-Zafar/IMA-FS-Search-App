# IMA-APP: PostgreSQL Deployment Guide

## Overview
This guide walks you through deploying the IMA Material Management System to SAP Business Technology Platform (BTP) Cloud Foundry environment with PostgreSQL database.

## Prerequisites

### Software Requirements
- [Node.js](https://nodejs.org/) (v20 or higher)
- [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
- [MTA Build Tool (MBT)](https://www.npmjs.com/package/mbt): `npm install -g mbt`
- [SAP CDS CLI](https://cap.cloud.sap/docs/get-started/installation): `npm install -g @sap/cds-dk`

### SAP BTP Requirements
- SAP BTP Global Account with Cloud Foundry Environment
- Subaccount with the following entitlements:
  - PostgreSQL (v9.4-dev plan)
  - SAP XSUAA Service
  - SAP HTML5 Application Repository
  - SAP Destination Service

## Quick Start Deployment

### Step 1: Setup Services
```bash
scripts\setup-postgres-services.bat
```

### Step 2: Build and Deploy
```bash
scripts\build-mta.bat
scripts\deploy-postgres.bat
```

## Detailed Deployment Steps

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

### Step 2: Setup PostgreSQL Services

1. **Create PostgreSQL service:**
   ```bash
   cf create-service postgresql v9.4-dev ima-app-db
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
   scripts\build-mta.bat
   ```
   
   Or manually:
   ```bash
   mbt build
   ```

2. **Deploy to Cloud Foundry:**
   ```bash
   scripts\deploy-postgres.bat
   ```
   
   Or manually:
   ```bash
   cf deploy mta_archives\ima-app_1.0.0.mtar
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

### Key Files for PostgreSQL:
- `mta.yaml` - Multi-Target Application descriptor (PostgreSQL configuration)
- `manifest.yml` - Cloud Foundry deployment manifest
- `xs-security.json` - XSUAA security configuration
- `package.json` - Updated with PostgreSQL dependencies (`@sap/cds-pg`)
- `.cdsrc.json` - CAP runtime configuration for PostgreSQL

## Environment-Specific Configurations

### Development Environment
- Uses SQLite in-memory database
- Mock authentication
- CORS enabled for localhost

### Production Environment
- PostgreSQL database
- XSUAA authentication
- Secure CORS policy

## PostgreSQL vs HANA Differences

### Advantages of PostgreSQL:
- ✅ **Faster setup** - No need for HANA Cloud instance
- ✅ **Trial-friendly** - Available in all BTP trial accounts
- ✅ **Cost-effective** - Lower resource requirements
- ✅ **Standard SQL** - Familiar SQL syntax
- ✅ **No auto-stop** - Unlike HANA Cloud in trials

### Limitations:
- ⚠️ **No SAP-specific features** - Missing some HANA analytics capabilities
- ⚠️ **Limited scalability** - For very large datasets
- ⚠️ **No SAP HANA XS** - Missing some SAP-specific extensions

## Troubleshooting

### Common Issues:

1. **PostgreSQL Service Creation Fails:**
   ```bash
   # Check available service plans
   cf marketplace | findstr postgres
   # Try different plan if v9.4-dev not available
   cf create-service postgresql [available-plan] ima-app-db
   ```

2. **Database Connection Issues:**
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

Your existing SQLite data has been preserved and will be migrated to PostgreSQL during deployment. The data model has been enhanced with:
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

## Local Development

For local development with PostgreSQL:

1. **Install PostgreSQL locally:**
   ```bash
   # Windows: Download from postgresql.org
   # Or use Docker:
   docker run --name postgres-dev -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
   ```

2. **Update .cdsrc.json for local PostgreSQL:**
   ```json
   "[development]": {
     "requires": {
       "db": {
         "kind": "postgres",
         "credentials": {
           "host": "localhost",
           "port": 5432,
           "database": "ima_dev",
           "username": "postgres",
           "password": "password"
         }
       }
     }
   }
   ```

## Support

For issues related to:
- **CAP Framework:** [SAP CAP Documentation](https://cap.cloud.sap/docs/)
- **PostgreSQL:** [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- **Cloud Foundry:** [CF Documentation](https://docs.cloudfoundry.org/)
- **SAP BTP:** [SAP Help Portal](https://help.sap.com/products/BTP)

---

**Note:** PostgreSQL is an excellent choice for trial environments and provides all the functionality needed for the IMA Material Management System.
