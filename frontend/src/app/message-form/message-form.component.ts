import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-message-form',
  imports: [CommonModule, FormsModule],
  templateUrl: './message-form.component.html',
  styleUrl: './message-form.component.css'
})
export class MessageFormComponent {
  message = {
    phoneNumber: '',
    message: ''
  };

  clearForm() {
    this.message = {
      phoneNumber: '',
      message: ''
    };
  }

  onSubmit() {
    console.log('Message submitted:', this.message);
  }
}
