package com.financeme.Banking;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class TestAccountService {

	@Autowired
	AccountService accountservice;
	
	@Test
	public void testAccountRegistration() {
		   Account account = new Account(1740341392,"Test","Current Account",2000.0);
		   assertEquals(account.getAccountNumber(),accountservice.registerDummyAccount().getAccountNumber());
		   assertEquals(account.getAccountName(),accountservice.registerDummyAccount().getAccountName());
	} 
	
}

