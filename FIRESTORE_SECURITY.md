# Firestore Security Rules

## Overview

This document describes the Firestore security rules implemented for the Flavormula F&B application.

## Security Rules

### File: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users to read/write their own recipes
    match /users/{userId}/recipes/{recipeId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Rule Explanation

### 1. User Document Access (`/users/{userId}`)
- **Condition**: `request.auth != null && request.auth.uid == userId`
- **Access**: Users can only read and write their own user document
- **Security**: Ensures users cannot access other users' personal information

### 2. Recipe Document Access (`/users/{userId}/recipes/{recipeId}`)
- **Condition**: `request.auth != null && request.auth.uid == userId`
- **Access**: Users can only read and write recipes that belong to them
- **Security**: Ensures users cannot access, modify, or delete other users' recipes

## Security Features

### Authentication Required
- All operations require user authentication (`request.auth != null`)
- Anonymous users cannot access any data

### User Isolation
- Users can only access their own data
- No cross-user data access is allowed
- Each user's data is completely isolated

### Data Structure
```
users/
├── {userId}/
│   ├── displayName: string
│   ├── email: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── recipes/
│       ├── {recipeId}/
│       │   ├── title: string
│       │   ├── ingredients: array
│       │   ├── createdAt: timestamp
│       │   └── updatedAt: timestamp
│       └── ...
└── ...
```

## Deployment

### Using Firebase CLI

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase** (if not already done):
   ```bash
   firebase init firestore
   ```

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Firestore Database
4. Click on "Rules" tab
5. Copy and paste the rules from `firestore.rules`
6. Click "Publish"

## Testing Rules

### Test Cases

1. **Authenticated user accessing own data**:
   - ✅ Should be able to read/write own user document
   - ✅ Should be able to read/write own recipes

2. **Authenticated user accessing other user's data**:
   - ❌ Should not be able to read other user's document
   - ❌ Should not be able to write to other user's document
   - ❌ Should not be able to read other user's recipes
   - ❌ Should not be able to write to other user's recipes

3. **Unauthenticated user**:
   - ❌ Should not be able to read any user documents
   - ❌ Should not be able to write any user documents
   - ❌ Should not be able to read any recipes
   - ❌ Should not be able to write any recipes

## Best Practices

1. **Always test rules** before deploying to production
2. **Use Firebase Emulator** for local testing
3. **Monitor Firestore usage** in Firebase Console
4. **Regular security audits** of the rules
5. **Keep rules simple** and avoid complex logic

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**:
   - Check if user is authenticated
   - Verify user ID matches document path
   - Ensure rules are properly deployed

2. **Rules Not Working**:
   - Clear browser cache
   - Check Firebase Console for rule deployment status
   - Verify rule syntax

3. **Testing Issues**:
   - Use Firebase Emulator for local testing
   - Check authentication state in your app
   - Verify document paths match rule structure

## Additional Security Considerations

1. **Data Validation**: Consider adding data validation rules
2. **Rate Limiting**: Implement rate limiting for write operations
3. **Audit Logging**: Consider logging access patterns
4. **Backup Strategy**: Implement regular data backups
5. **Monitoring**: Set up alerts for unusual access patterns
