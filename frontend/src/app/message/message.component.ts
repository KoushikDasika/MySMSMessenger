import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DateTime } from 'luxon';

@Component({
  selector: 'app-message',
  imports: [CommonModule],
  templateUrl: './message.component.html',
  styleUrl: './message.component.css'
})
export class MessageComponent {
  @Input() message: any;
  
  formatSentAt(sentAt: string) {
    const dt = DateTime.fromISO(sentAt).setZone('UTC');
    return dt.toFormat('EEEE, dd-MMM-yyyy HH:mm:ss \'UTC\'');
  }
}
