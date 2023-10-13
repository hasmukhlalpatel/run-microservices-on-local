import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UnicornComponentComponent } from './unicorn-component.component';

describe('UnicornComponentComponent', () => {
  let component: UnicornComponentComponent;
  let fixture: ComponentFixture<UnicornComponentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ UnicornComponentComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(UnicornComponentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
