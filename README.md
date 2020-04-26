# cashless-exercise-modeling

# Problem

Let's say you worked at some hot tech unicorn company for a number of years where you vested a combination of highly valuable NSOs, ISOs, and/or RSUs. Due to the high risk involved you decided not to exercise any of these options upfront. Or maybe you only exercised partially since it was a lot of cash commitment to exercise everything you vested.

After the company IPOs, say you now believe the stock will be worth much more in the future than in the present (say at least 30% higher to make this optimization worth it). So you decide you want to sell just enough to cover taxes, and hold as much as possible for the long term (at least 1 year out to qualify for long term capital gains rates).

If you have only RSUs, then there's no "optimization" needed since you are going to get taxed on the RSUs whether you sell or not (RSUs are taxed both on vest as well as selling). As long as you sell enough RSUs to cover your taxes, you can just hold on to the rest for as long as you like. You can use this script to try and estimate your tax owing, so you can make sure both you and your company sell enough stock to cover your tax liability the following April.

However, things get interesting if you have a combination of options as well as RSUs, or just options. How do you know which and how many options/RSUs to sell and which to hold? How do I estimate how much extra I need to sell to cover taxes on both sides? (You will owe taxes both on selling as well as exercising and holding.)


# Solution

So given an arbitrary set of ISO, NSO, and RSU grants with varying strike prices and stock counts, this script helps you compute the maximum number of shares that can be exercised and held for close to $0 money upfront, taking into account all taxes (including AMT).

In this scenario, you begin by selling all your RSUs first (since they will already be taxed), then your NSOs, then your ISOs, in that order. ISOs are the most tax advantaged, so you sell those last. RSUs are least tax advantaged, so you sell those first. You keep selling your grants in that order until the after-tax income generated via these sells roughly equals the cost of exercising and holding the remaining grants, including any applicable taxes on exercise. This is the premise of a "cashless exercise".

In this scenario, you don't have to put in any of your own money upfront. You simply convert a basket of NSOs/RSUs/ISOs into a single basket of actual shares (no longer options), albeit with varying tax bases. This process also increases your diversification by reducing your single-stock concentration risk as compared to exercising and holding with your own cash (ie. no selling to cover).

# How to Use

    # copy over the template
    $ cp grants_private.template.rb grants_private.rb

    # input your grants here
    $ vim grants_private.rb

    # run the script!
    $ ruby main.rb


# Pull Reqeusts

If you can make this tool better, please do! Fork the repo, and submit a pull request for review. Bug fixes also welcome.


# Todo

  * This script assumes you're tax filing status is Married Filing Jointly. It would be nice to also support Single filing, as many young people in their 20s and early 30s are likely still unmarried.

  * Write unit tests :)

# Disclaimer

I'm **not** a tax professional, and don't have a accounting, finance, or tax degree. Use this tool and scripts at your own risk. The math has **NOT** been verified by a finance or tax professional.

These scripts are provided solely for personal use, and is not meant to be construes as financial or tax advice. Use this tool to simply get a general idea of your stock situation, and then go talk to a real Certified Financial Planner (CFP), CPA, or tax specialist before you make any decisions to sell, not sell, or exercise any stock options / shares. The scripts contained make a number of simplifying assumptions to keep the math from becoming too complicated. Be sure to update the math for your specific situation. All tax rates, thresholds, and amounts are as of 2020. Future rates and thresholds are likely to be different.

This script also doesn't claim your company's stock price will always go up monotonically, even if it may assume it in some calculations.