import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import { withFetch, withInterceptors } from '@angular/common/http';
import { provideHttpClient } from '@angular/common/http';
import { environment } from '../environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withFetch(), withInterceptors([
      (req, next) => {
        // Get session ID from localStorage or another storage mechanism
        const sessionId = localStorage.getItem('sessionId');
        
        // Clone the request with the API URL prefix
        req = req.clone({
          url: `${environment.apiUrl}${req.url}`,
          // Add session ID as a cookie in the headers if it exists
          setHeaders: sessionId ? {
            'Cookie': `sessionId=${sessionId}`,
            // Also add it as a custom header for APIs that might not support cookies
            'X-Session-ID': sessionId
          } : {}
        });
        
        return next(req);
      }
    ]))
  ]
};
