import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MessageFormComponent } from './message-form.component';
import { ReactiveFormsModule } from '@angular/forms';
import { MessageService } from '../core/message.service';
import { of, throwError } from 'rxjs';

describe('MessageFormComponent', () => {
  let component: MessageFormComponent;
  let fixture: ComponentFixture<MessageFormComponent>;
  let messageServiceSpy: jasmine.SpyObj<MessageService>;

  beforeEach(async () => {
    // Create spy for MessageService
    messageServiceSpy = jasmine.createSpyObj('MessageService', ['sendMessage']);
    
    await TestBed.configureTestingModule({
      imports: [MessageFormComponent, ReactiveFormsModule],
      providers: [
        { provide: MessageService, useValue: messageServiceSpy }
      ]
    })
    .compileComponents();

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
    messageServiceSpy.sendMessage.and.returnValue(of({
      to: '+12025550123',
      body: 'Test message',
      sent_at: '2023-01-01T00:00:00Z'
    }));
    
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
    
    component.onSubmit();
    
    expect(messageServiceSpy.sendMessage).toHaveBeenCalledWith({
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
    messageServiceSpy.sendMessage.and.returnValue(throwError(() => new Error('Test error')));
    
    component.messageForm.setValue({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
    
    component.onSubmit();
    
    expect(messageServiceSpy.sendMessage).toHaveBeenCalled();
    expect(component.submitting).toBeFalse();
    // Form should not be reset on error
    expect(component.messageForm.value).toEqual({
      body: 'Test message',
      phoneNumber: '+12025550123'
    });
  });
});
