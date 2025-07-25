# World Computer Lottery

https://dashboard.internetcomputer.org/canister/yabps-hqaaa-aaaar-qbsha-cai

Note that the [frontend canister](https://yhajg-kiaaa-aaaar-qbshq-cai.icp0.io/) is segregated and maintained in a [separate repo](https://github.com/aodl/WorldComputerLotteryFrontend). The backend canister is maintained in this separate repo, as it's designed to be fully functional with minimal dependencies and easy to review and verify.

The World Computer Lottery represents a three-pronged approach to advancing awareness and engagement on the Internet Computer, seeking to improve the experience of,
1. everyday users,
2. governance participants, and
3. developers.

------

1. Everyday Users - *Build it and they will come*
- Most everday people are still unfamilar with Web3 technologies, as the benefits and use cases can sometimes be difficult to grasp. However, most people are familiar with the concept of a lottery, and many regularly take part in national lotteries. The benefits of a decentralised, trustless, fully-verifiable lottery, should be clear to the vast majority of people. While national lotteries often take a huge portion of the ticket revenue and/or redistribute it to charities and other organisations, the World Computer Lottery puts the player in charge. 100% of the ticket costs are allocated to the Jackpot that is distributed to players if they opt out of a small 1% donation to improving governance and security on the Internet Computer.

2. Governance Participants - *Secure it and they will stake*
- Most users on the Internet Computer do not have much time to engaged in governance and NNS proposal reviews. Yet these are what secure the network and protect everyone's stake. Initiatives such as [D-QUORUM](https://dashboard.internetcomputer.org/neuron/4713806069430754115) and [ALPHA-Vote](https://github.com/aodl/ALPHA-Vote) are intended to reduce friction around around governance, and make it easier for the community to make the most of the NNS while ensuring the NNS gets the best ouf the community. An optional donation to the D-QUORUM stake will be built into the World Computer Lottery (capped at no more than 1% of the cost of tickets). This ensures the safety of the jackpot hosted by the network, and also ensures the integrity and sanctity of the smart contracts running on the Internet Computer (including the lottery itself). 

3. Developers - *Fuel it and make it unstoppable*
- If a World Computer Lottery is to have large funds flowing through it, it needs to be easy to trust, either by blackholing the smart contract of assigning sole control to the NNS. However a smart contract cannot be considered unstoppable and independent if it can run out of cycles/gas. The World Computer Lottery therefore needs a perpetual supply of cycles that is not dependent on any individual (both in terms of the source of funds, and the action of topping up the canister). A sister project is underway to faciliate this feature (a link to that repo will be added soon). This feature will be re-usable and easily applicable to any and all canisters a developer may wish to establish perpetual cycles for, thereby improving the developer experience and making it easier to build unstoppable dapps that showcase IC capabilities.

## How to Play

You can participate in the World Computer Lottery either via a [dedicated user interface](https://github.com/aodl/WorldComputerLotteryFrontend/edit/master/README.md#how-to-play), or via a command line interface, such as dfx. Here is an example of purchasing a ticket:

```
dfx ledger transfer b2f9bc1fc7ee9151715a04c0933b03d49042f9b1ec1d064e3a2e46f804825d33 --amount=0.01 --memo=1112131415161718 --network=ic
```

In the above example the chosen lottery numbers are 11, 12, 13, 14, 15, 16, 17, 18 (concatenated into the memo). Tickets cost 0.01 ICP. b2f9bc1fc7ee9151715a04c0933b03d49042f9b1ec1d064e3a2e46f804825d33 is the ledger account for the canister.

You can also review the logs via dfx (`dfx canister logs yabps-hqaaa-aaaar-qbsha-cai --network=ic`). Log visibility is set to public. Here's are some example logs:

```
[5763. 2025-07-25T06:04:37.510504246Z]: ---------- WORLD COMPUTER LOTTERY, Draw No.1152 (demo) ----------
[5764. 2025-07-25T06:04:42.365410641Z]: NUMBERS, [24, 57, 66, 96, 6, 56, 58, 9]
[5765. 2025-07-25T06:04:45.626716119Z]: TICKETS COLLECTED, 0 (up to transaction 25975552)
[5766. 2025-07-25T06:04:45.626716119Z]: WINNERS, none
[5767. 2025-07-25T06:04:45.626716119Z]: JACKPOT ROLLOVER, 0.048706 ICP
[5768. 2025-07-25T06:05:37.82630275Z]: ---------- WORLD COMPUTER LOTTERY, Draw No.1153 (demo) ----------
[5769. 2025-07-25T06:05:42.346861882Z]: NUMBERS, [48, 26, 77, 27, 43, 42, 99, 52]
[5770. 2025-07-25T06:05:46.06902536Z]: TICKETS COLLECTED, 0 (up to transaction 25975552)
[5771. 2025-07-25T06:05:46.06902536Z]: WINNERS, none
[5772. 2025-07-25T06:05:46.06902536Z]: JACKPOT ROLLOVER, 0.048706 ICP
[5773. 2025-07-25T06:06:37.864951064Z]: ---------- WORLD COMPUTER LOTTERY, Draw No.1154 (demo) ----------
[5774. 2025-07-25T06:06:46.509883653Z]: NUMBERS, [62, 45, 30, 69, 13, 35, 46, 84]
[5775. 2025-07-25T06:06:53.240785842Z]: TICKETS COLLECTED, 0 (up to transaction 25975552)
[5776. 2025-07-25T06:06:53.240785842Z]: WINNERS, none
[5777. 2025-07-25T06:06:53.240785842Z]: JACKPOT ROLLOVER, 0.048706 ICP
[5778. 2025-07-25T06:07:38.076136104Z]: ---------- WORLD COMPUTER LOTTERY, Draw No.1155 (demo) ----------
[5779. 2025-07-25T06:07:49.010020252Z]: NUMBERS, [36, 5, 45, 8, 83, 27, 98, 89]
[5780. 2025-07-25T06:07:57.30173058Z]: TICKETS COLLECTED, 0 (up to transaction 25975552)
[5781. 2025-07-25T06:07:57.30173058Z]: WINNERS, none
[5782. 2025-07-25T06:07:57.30173058Z]: JACKPOT ROLLOVER, 0.048706 ICP
[5783. 2025-07-25T06:08:40.262738714Z]: ---------- WORLD COMPUTER LOTTERY, Draw No.1156 (demo) ----------
[5784. 2025-07-25T06:08:49.753498257Z]: NUMBERS, [84, 34, 59, 28, 21, 69, 63, 6]
[5785. 2025-07-25T06:09:00.558210657Z]: TICKETS COLLECTED, 2 (up to transaction 26019111)
[5786. 2025-07-25T06:09:00.558210657Z]: WINNERS, 🎯: 1
[5787. 2025-07-25T06:09:00.558210657Z]: JACKPOT, 0.068706 ICP
[5788. 2025-07-25T06:09:00.558210657Z]: Tier 1               🎯: 1% of 0.068706 ICP Jackpot between 1 winner(s), minus 0.000100 transfer fee = 0.000587 ICP payout each
[5789. 2025-07-25T06:09:04.748148702Z]: Canister ledger account b2f9bc1fc7ee9151715a04c0933b03d49042f9b1ec1d064e3a2e46f804825d33 proves payouts and ticket purchases
[5790. 2025-07-25T06:09:40.519190281Z]: ---------- WORLD COMPUTER LOTTERY, Draw No.1157 (demo) ----------
[5791. 2025-07-25T06:09:45.869363126Z]: NUMBERS, [65, 97, 88, 15, 47, 66, 17, 44]
[5792. 2025-07-25T06:09:51.980632476Z]: TICKETS COLLECTED, 2 (up to transaction 26019192)
[5793. 2025-07-25T06:09:51.980632476Z]: WINNERS, none
[5794. 2025-07-25T06:09:51.980632476Z]: JACKPOT ROLLOVER, 0.088019 ICP
```

Logs are also [visible via a frontend](https://github.com/aodl/WorldComputerLotteryFrontend/edit/master/README.md#logs)

## Architecture

No public endpoints (other than logs), to avoid potential for cycle drain attacks, give that the plan is to either blackhole the canister or assign control the NNS.

As much as possible, the intention is to adhere to a microservices architecture, where various features are decoupled and segregated into reusable and/or replaceable parts. Additional features to be added included a staking service which uses yield to top up canisters forever, lifetime tickets (pick your numbers once, and play the lottery forever), automated neuron voting to ensure yield isn't lost etc.

## Build Reproducibility

TODO, build instructions

## Testing

TODO, notes about running the tests
