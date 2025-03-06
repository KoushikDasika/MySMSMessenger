import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DateTime } from 'luxon';
import { parsePhoneNumber } from 'awesome-phonenumber'

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
  
  formatPhoneNumber(phoneNumber: string) {
    console.log('phoneNumber', phoneNumber);
    const parsed = parsePhoneNumber(phoneNumber);
    const significantNumber = parsed.number?.significant;
    if (!significantNumber) {
      return phoneNumber;
    }
    const areaCode = significantNumber.slice(0, 3);
    const prefix = significantNumber.slice(3, 6);
    const lineNumber = significantNumber.slice(6);
    return `${areaCode}-${prefix}-${lineNumber}`;
  }
}
