import { TestBed } from '@angular/core/testing';

import { EverythingServiceService } from './everything-service.service';

describe('EverythingServiceService', () => {
  let service: EverythingServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(EverythingServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
