import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, Subject, tap } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  private newMessageSubject = new Subject<any>();
  
  // Observable that components can subscribe to
  newMessage$ = this.newMessageSubject.asObservable();
  
  constructor(private http: HttpClient) { }
  
  getMessages(): Observable<any> {
    return this.http.get('/api/messages', { withCredentials: true });
  }

  sendMessage({phoneNumber, messageBody}: {phoneNumber: string, messageBody: string}): Observable<any> {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });

    return this.http.post('/api/messages', { to: phoneNumber, body: messageBody }, { headers, withCredentials: true })
      .pipe(
        tap((response: any) => {
          // Emit the new message to all subscribers
          this.newMessageSubject.next(response);
        })
      );
  }
}