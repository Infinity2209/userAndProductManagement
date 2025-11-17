#!/bin/bash

# Deploy script for Netlify with JSON Server backend

echo "🚀 Starting deployment process..."

# Check if JSON server URL is provided
if [ -z "$JSON_SERVER_URL" ]; then
    echo "❌ Error: JSON_SERVER_URL environment variable is not set"
    echo "Please set your JSON server URL:"
    echo "export JSON_SERVER_URL=https://your-json-server.herokuapp.com"
    echo ""
    echo "Example:"
    echo "export JSON_SERVER_URL=https://my-json-server.herokuapp.com"
    echo "./deploy.sh"
    exit 1
fi

# Validate URL format
if [[ ! $JSON_SERVER_URL =~ ^https:// ]]; then
    echo "❌ Error: JSON_SERVER_URL must start with https://"
    echo "Please provide a valid HTTPS URL for your JSON server"
    exit 1
fi

# Remove trailing slash if present
JSON_SERVER_URL=${JSON_SERVER_URL%/}

echo "🔗 Using JSON server URL: $JSON_SERVER_URL"

# Update netlify.toml with the actual JSON server URL
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|https://your-json-server-endpoint.herokuapp.com|$JSON_SERVER_URL|g" netlify.toml
else
    # Linux/Windows
    sed -i "s|https://your-json-server-endpoint.herokuapp.com|$JSON_SERVER_URL|g" netlify.toml
fi

echo "✅ Updated netlify.toml with JSON server URL"

# Build the project
echo "🔨 Building the project..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully"

# Check if netlify-cli is available
if ! command -v netlify &> /dev/null && ! npx netlify --version &> /dev/null; then
    echo "⚠️  Netlify CLI not found. Installing temporarily..."
    npx netlify --version > /dev/null 2>&1 || npm install -g netlify-cli
fi

# Deploy to Netlify
echo "🌐 Deploying to Netlify..."
npx netlify deploy --prod --dir=dist

if [ $? -eq 0 ]; then
    echo "🎉 Deployment successful!"
    echo "Your app should now work with the JSON server backend."
    echo ""
    echo "📋 Next steps:"
    echo "1. Make sure your JSON server is running and accessible at: $JSON_SERVER_URL"
    echo "2. Test the deployed app to ensure API calls work"
    echo "3. If you encounter CORS issues, configure your JSON server to allow requests from your Netlify domain"
else
    echo "❌ Deployment failed!"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "1. Check your JSON server URL is correct and accessible"
    echo "2. Ensure you have proper permissions for Netlify deployment"
    echo "3. Try deploying manually: npx netlify deploy --prod --dir=dist"
    exit 1
fi
