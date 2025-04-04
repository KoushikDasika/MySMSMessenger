import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MessageListComponent } from '@/app/messages/message-list/message-list.component';
import { MessageFormComponent } from '@/app/messages/message-form/message-form.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, MessageListComponent, MessageFormComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'my-sms-messenger';
}
