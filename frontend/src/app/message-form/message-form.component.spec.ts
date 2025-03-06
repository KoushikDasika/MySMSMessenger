import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MessageFormComponent } from './message-form.component';
import { ReactiveFormsModule } from '@angular/forms';
import { MessageService } from '../core/message.service';
import { of, throwError } from 'rxjs';
import { fakeAsync, tick, flush } from '@angular/core/testing';

describe('MessageFormComponent', () => {
  let component: MessageFormComponent;
  let fixture: ComponentFixture<MessageFormComponent>;
  let messageService: jasmine.SpyObj<MessageService>;

  beforeEach(async () => {
    // Create spy for MessageService
    const messageSpy = jasmine.createSpyObj('MessageService', ['sendMessage']);

    await TestBed.configureTestingModule({
      imports: [MessageFormComponent, ReactiveFormsModule],
      providers: [
        { provide: MessageService, useValue: messageSpy }
      ]
    }).compileComponents();

    messageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
    fixture = TestBed.createComponent(MessageFormComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize form with empty values', () => {
    expect(component.messageForm.value).toEqual({
      body: '',
      phoneNumber: ''
    });
  });

  it('should validate required fields', () => {
    const bodyControl = component.messageForm.get('body');
    const phoneControl = component.messageForm.get('phoneNumber');
    
    bodyControl?.setValue('');
    phoneControl?.setValue('');
    
    expect(bodyControl?.valid).toBeFalsy();
    expect(phoneControl?.valid).toBeFalsy();
    expect(bodyControl?.errors?.['required']).toBeTruthy();
    expect(phoneControl?.errors?.['required']).toBeTruthy();
  });

  it('should validate message length', () => {
    const bodyControl = component.messageForm.get('body');
    
    // Valid length
    bodyControl?.setValue('Hello world');
    expect(bodyControl?.valid).toBeTruthy();
    
    // Invalid length (over MAX_LENGTH)
    bodyControl?.setValue('a'.repeat(component.MAX_LENGTH + 1));
    expect(bodyControl?.valid).toBeFalsy();
    expect(bodyControl?.errors?.['maxlength']).toBeTruthy();
  });

  it('should validate phone number format', () => {
    const phoneControl = component.messageForm.get('phoneNumber');
    
    // Valid E.164 format
    phoneControl?.setValue('+12025550123');
    expect(phoneControl?.valid).toBeTruthy();
    
    // Invalid format
    phoneControl?.setValue('1234');
    expect(phoneControl?.valid).toBeFalsy();
  });

  it('should clear form when clearForm is called', () => {
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
    
    component.clearForm();
    
    expect(component.messageForm.value).toEqual({
      body: null,
      phoneNumber: null
    });
  });

  it('should call messageService when form is submitted successfully', () => {
    messageService.sendMessage.and.returnValue(of({
      to: '+12025550123',
      body: 'Test message',
      sent_at: '2023-01-01T00:00:00Z'
    }));
    
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
    
    component.onSubmit();
    
    expect(messageService.sendMessage).toHaveBeenCalledWith({
      phoneNumber: '+12025550123',
      messageBody: 'Test message'
    });
    
    expect(component.submitting).toBeFalse();
    expect(component.messageForm.value).toEqual({
      body: null,
      phoneNumber: null
    });
  });

  it('should handle errors when message submission fails', () => {
    messageService.sendMessage.and.returnValue(throwError(() => new Error('Test error')));
    
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
    
    component.onSubmit();
    
    expect(messageService.sendMessage).toHaveBeenCalled();
    expect(component.submitting).toBeFalse();
    // Form should not be reset on error
    expect(component.messageForm.value).toEqual({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
  });

  it('should display success message when message is sent successfully', () => {
    // Set up form with valid values
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });

    // Mock successful response
    messageService.sendMessage.and.returnValue(of({
      to: '+12025550123',
      body: 'Test message',
      sent_at: '2023-01-01T00:00:00Z'
    }));

    // Submit form
    component.onSubmit();
    fixture.detectChanges();

    // Check that success message is displayed
    expect(component.showSuccess).toBeTrue();
    expect(component.successMessage).toBe('Message sent successfully!');
    expect(component.showError).toBeFalse();
  });

  it('should display error message when message sending fails', () => {
    // Set up form with valid values
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });

    // Mock error response
    const errorResponse = { 
      error: { message: 'Server error occurred' } 
    };
    messageService.sendMessage.and.returnValue(throwError(() => errorResponse));

    // Submit form
    component.onSubmit();
    fixture.detectChanges();

    // Check that error message is displayed
    expect(component.showError).toBeTrue();
    expect(component.errorMessage).toBe('Failed to send message. Please try again.');
    expect(component.showSuccess).toBeFalse();
  });

  it('should display generic error message when error has no message', () => {
    // Set up form with valid values
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });

    // Mock error response without specific message
    messageService.sendMessage.and.returnValue(throwError(() => new Error()));

    // Submit form
    component.onSubmit();
    fixture.detectChanges();

    // Check that generic error message is displayed
    expect(component.showError).toBeTrue();
    expect(component.errorMessage).toBe('Failed to send message. Please try again.');
    expect(component.showSuccess).toBeFalse();
  });

  it('should clear feedback messages when form is cleared', () => {
    // Set error state
    component.showError = true;
    component.errorMessage = 'Test error';

    // Clear form
    component.clearForm();

    // Check that messages are cleared
    expect(component.showError).toBeFalse();
    expect(component.errorMessage).toBe('');
    expect(component.showSuccess).toBeFalse();
    expect(component.successMessage).toBe('');
  });

  it('should hide success message after timeout', fakeAsync(() => {
    // Set up form with valid values
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });

    // Mock successful response
    messageService.sendMessage.and.returnValue(of({
      to: '+12025550123',
      body: 'Test message',
      sent_at: '2023-01-01T00:00:00Z'
    }));

    // Submit form - this will trigger the actual setTimeout in the component
    component.onSubmit();

    // Verify success message is shown
    expect(component.showSuccess).toBeTrue();

    // Fast-forward time to trigger the timeout
    tick(5000);

    // Check that success message is hidden
    expect(component.showSuccess).toBeFalse();

    // Clean up any pending timers
    flush();
  }));
});
