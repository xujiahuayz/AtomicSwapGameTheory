AFT 2020 Paper #9 Reviews and Comments
===========================================================================
Paper #9 A Game-Theoretic Analysis of Cross-Ledger Atomic Swap Protocols


Review #9A
===========================================================================

Overall merit
-------------
2. Weak reject

Reviewer expertise
------------------
2. Some familiarity

Paper summary
-------------
This paper does a game-theoretic model of hash time lock contracts (HTLCs).  The episodic nature of HTLCs naturally lends itself to a multi-stage game model (Alice chooses whether or not to post the contract on her side, Bob chooses whether to post the contract on his side, and Alice chooses whether or not to release her secret key).  What's interesting game-theoretically is that, because of time discounting and price volatility, Alice might choose to bail in the third step (declining the option that she effectively has) if a price change has rendered the trade unfavorable, and Bob might choose to bail in the second step (if the current price suggests that Alice will bail in the third step, anyways).  The overall structure of the game-theoretic model is a good balance of simplicity and fidelity.   Conceptually, one can solve for a canonical Nash equilibrium of the game via backward induction.  Solving analytically for this equilibrium appears difficulty, so that authors investigate it numerically.  The qualitative effects are as expected (e.g. volatility and transaction delays decrease completion rate), but it is good to see them treated in a precise way.  ("Completion rate" is the probability of completion over the price trajectory, which is modeled via Brownian motion.)  The least satisfying aspect of the analysis is the arbitrary choice of a large number of parameters in the model; because of this, it's not clear to what extent the quantitative findings of the paper would hold more generally.
The last section offers two extensions.  The first is possibly the most interesting takeaway of the paper, showing that collateral (to be forfeited to the other party on withdrawal from the process) can significantly boost success rate, at least for the particular parameters studied.  It would be interesting to understand this point more generally.  The second extension add a little uncertainty in one of the parameters of each party (their "success premium"); the point of this section is not clear to me.

Comments for author
-------------------
- [x] "backwardization" -> "backward induction"
- [x] inequality (4) is reversed



Review #9B
===========================================================================

Overall merit
-------------
2. Weak reject

Reviewer expertise
------------------
3. Knowledgeable

Paper summary
-------------
This paper studies a game-theoretical model of a cross-ledger atomic swap protocol, Hash Time Locked Contracts, which is modeled as a four steps game.
1, initiate the transaction on the first ledge with a smart contract by player A; 
2, create a corresponding smart contract on the second ledge by player B; 
3, accept the contract in the second ledge by player A; 
4, finish the transaction on the first ledge by player B. 
Each player moves once at each step or terminates the game. The authors analyze the best response of players at each step and consider the success rate under different scenarios with different settings- normal HTLCs, HTLCs with collateral, and partial information game (uncertain success premium).
This paper follows the game theoretical framework of atomic cross-chain swap protocol and gives a more detailed analysis.

Comments for author
-------------------
This paper gives a quantitative analysis of atomic cross-chain swap protocol, there are several advantages of this paper.
   1. This paper modeled the utility function of agents in the cross-chain swap protocol and analyzed these values in the extensive-form game, which specific previous qualitative analysis model.
   2. This paper considered additional assumptions on top of the basic model and compared the results with the basic model.


However, it is not clear how this paper contributes to the area because of following concerns. 
   1. The model is limited. It can not be applied to general cross-chain swaps.
   2. Some assumption are not practical, e.g., zero waiting time. This makes the final result not convincing.
   3. It is not clear why we should care about success rate and reputation in the first place. How does it matter in future transactions? In case of UTXOs certainly not. And even with account-based systems, somebody can just boost its reputation by swapping with oneself?


Furthermore, the presentation can be improved as well.

- [ ] Ethers *JX: what's that?*
- [x] Decide not [to] follow.
- [x] First, it will be better to use consistent presentation of set-up or setup, one-time or onetime

Abstract

- [x] decide not follow -> decide not to follow
- [x] collaterization -> collateralization 

Introduction

- [x] evidences -> evidence
- [x] They allow to execute larger orders -> They were allow to execute larger orders *JX: deleted*
- [x] with negotiated price -> with a negotiated price
- [x] agents’s -> agents’

Section 2

- [x] in distributed manner -> in a distributed manner
- [x] coordination mechanism -> coordination mechanisms
- [x] aiming to achieving atomicity -> aiming to achieve atomicity
...


These are questions for authors. 
1. How do you choose the default value of parameters in Table 3? How do you choose the time scale in the model? Because these values seriously influence the final results.
2. The success rate is highly related to the token price function, have you considered using some real market data to simulate the model?
3. The results seem intuitive. Do you have any more exciting findings other than this?



Review #9C
===========================================================================

Overall merit
-------------
1. Reject

Reviewer expertise
------------------
3. Knowledgeable

Paper summary
-------------
The paper studies atomic swaps on two different blockchains: Alice wishes to send A amount of one asset to Bob and Bob wishes to send B amount of another asset to Alice. The particular technique studied is the HTLCs (Hashed Time Lock Contracts).

The protocol proceeds as follows: In Chain 1, Alice offers A to Bob before time TA if someone can reveal Alice's key. After time TA, if Bob has not yet revealed Alice's key, Alice has A refunded. After Alice posts her transaction, in chain 2, Bob offers B to Alice before time TB if Alice reveals her key. After time TB, if Alice has not yet revealed her key, Bob has B refunded. Assuming that TB < TA. Alice reveals her key before time TB to unlock B and Bob can use her key to unlock A in the first chain. By definition, Alice can abort the protocol before revealing her key (with no penalties) and Bob can abort the protocol before posting his offer.

The main observation is that A and B are in different currencies. The paper aims to study how the variation in the value of the assets with respect to each other can affect the incentives to either Alice or Bob to abort the protocol. Let P(t) be the price of asset A with respect to asset B. The paper consider a model where P(t) follows a Brownian motion with positive drift \mu and variance \sigma. The drift is deterministic implying that the value of A is believed to be increasing with respect to asset B. The model also assumes a deterministic discount rate of both assets.

To increase the incentive for Alice and Bob not aborting. The paper considers an extension of the model where Alice and Bob deposit as collateral in case either aborts the protocol. This increases the probability that no agent aborts the protocol. 

The paper proposes an interesting model to study the chance of success of atomic transfer but I felt that parts of the model need more justification. I describe my main concerns in the Major Comments section. Also, the quality of writing would benefit from more proof-reading. Some sections are hard to follow and there is a significant amount of typos through the paper. The quality of figures and graphs are great.

Comments for author
-------------------
Major Comments
The paper does not give a clear picture of the time scale of atomic swaps. 

- [ ] If the deadlines TA and TB are in the order of days or even hours, I can imagine that variations in asset pricing might create incentives for aborting; however, if TA and TB are in the order of a few second or minutes I don't feel the paper is modeling a relevant phenomenon. The paper could give more justification by giving examples of the atomic swaps and real values for TA and TB.

- [ ] I felt the model had little justification. In particular, by assuming a positive drift \mu implies that Alice would never want to exchange asset A for asset B since P(t) goes to infinite (with probability 1). The paper gets away with that by assuming that Alice only cares about p(t) until TA, but no justification is given. 

The paper is also assuming a deterministic discount rate of the assets (which again depends on the time scale of TA and TB). So looks like the Claims that Alice would want to abort the swap are just driven by an obvious observation because if you consider the infinite horizon Alice would never start the exchange in the first place. In fact, under positive drift even with collaterals, with high probability Alice will always abort given enough time TA.

The paper could still be interesting assuming no drift when TA and TB have large timescale but it chose to be overly complicated without giving clear reasons for the complicated model.

Minor Comments

- [x] Abstract: key-words separated by a semi-colon *JX: does not apply to SP template*
- [ ] In the related work section, you mention that a downside of relays, sidechains, etc… require contracts. But aren't HTLCs contracts too? *AD & DA?*
- [ ] You mention a discussion in a blog that says that 5% of transactions fail. You might want to add a reference to that discussion. *AD & DA?*



Review #9D
===========================================================================

Overall merit
-------------
2. Weak reject

Reviewer expertise
------------------
1. No familiarity
