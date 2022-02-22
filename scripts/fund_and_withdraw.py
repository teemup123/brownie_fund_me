from brownie import FundMe
from scripts.helpful_scipts import get_account

def fund():
    fund_me = FundMe[-1]
    account = get_account()
    enterance_fee = fund_me.getEntranceFee()
    print("the current enterance fee is: {}".format(enterance_fee))
    
    print("Funding...")
    fund_me.fund({
        "from": account,
        "value": enterance_fee 
    })

def withdraw(): 
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({
        "from": account,
    })


def main():
    fund()
    withdraw()