import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MessageListComponent } from './message-list/message-list.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, MessageListComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'my-sms-messenger';
}
