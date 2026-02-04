# Open P2P Challenges - Quick Q&A

## Q1: When does Chat open? Notification if user doesn't open it?

**When Chat Opens:**
- After **both stakes are locked** in escrow (challenge status = `ACTIVE`)
- User can navigate to `/chat/{challengeId}` or click chat icon
- ✅ Chat is **always accessible** once active

**If User Doesn't Open Chat:**
- ✅ **YES**, notifications are sent:
  - "⚔️ Challenge Started" - Real-time notification
  - "⏰ Voting Deadline Alert" - 5 mins before voting ends
  - "⚔️ Opponent Submitted Proof" - When opponent uploads evidence
- Backend jobs run every 60 seconds to send reminders

---

## Q2: Does "Accept" button change to "Ongoing/Active"? Back to "Accept" on refund?

**Button Status Changes:**

| Status | Button | Action |
|--------|--------|--------|
| `open` | **Accept** | Opens stake modal |
| `active` | **Ongoing** | Opens chat (voting phase) |
| `disputed` (refund requested) | **Decide** | Accept/Decline refund buttons appear |
| `refunded` | **Cancelled** | Challenge ended |

✅ **YES** - Button changes dynamically based on challenge status

---

## Q3: How does Refund happen during chat?

**Refund Flow (Off-Chain):**

1. Either player clicks **"Request Refund"** in chat
2. Reason is recorded in database
3. Other player gets notified: "Refund requested"
4. Buttons appear: **[Accept Refund]** or **[Decline]**

**If Accepted:**
```
1. API call: POST /api/challenges/{id}/accept-refund
2. Status → REFUNDED
3. Backend calls escrow: releaseStakes()
4. Both stakes returned to original owners
5. Challenge cancelled
```

**If Declined:**
```
1. Status stays ACTIVE
2. Challenge continues to voting
3. Both must submit proof and vote
```

**Note:** Refund is **off-chain database transaction**, not on smart contract. Escrow release happens via smart contract after mutual agreement.

---

## Q4: How does Voting happen? Is contract updated for voting?

**Voting Flow (Off-Chain Voting → On-Chain Release):**

1. **Voting Phase:** Starts after both proofs submitted
   - `votingEndsAt` timestamp set
   - Each player clicks vote button: **"Creator Won" / "Draw" / "Acceptor Won"**
   - Stored in DB: `creatorVote` and `acceptorVote`

2. **Contract Status:** 
   - ❌ **NO voting logic on contract** (not needed)
   - Contract only manages escrow: `lockStake()` and `releaseStake()`
   - Winner determined **off-chain**, then contract releases stake

3. **Settlement (After Voting Ends):**
   ```
   IF both voted same winner:
     → Winner declared automatically
     → Backend calls escrow.releaseStake(winner, 200 USDC)
   
   ELSE (disagreement or timeout):
     → Goes to DISPUTED
     → Admin reviews chat/proof
     → Admin calls contract.resolveChallenge(winner)
   ```

**Contract Functions for Voting/Settlement:**
```solidity
// Not implemented yet - voting is off-chain
// Settlement happens via:
function releaseStake(uint256 challengeId, address winner) 
  // Called by escrow to transfer winner's 200 USDC
```

---

## Quick Summary

| Feature | Status |
|---------|--------|
| Chat auto-opens | ✅ After both stake |
| Chat notifications | ✅ Real-time + reminders |
| Button state changes | ✅ Dynamic based on status |
| Refund flow | ✅ Off-chain mutual agreement |
| Voting | ✅ Off-chain, stored in DB |
| Contract voting logic | ❌ Not needed (off-chain) |
| Escrow release | ✅ Smart contract handles |

---

## Database Fields for Voting

```typescript
creatorVote: varchar        // 'creator_id', 'acceptor_id', or 'draw'
acceptorVote: varchar       // 'creator_id', 'acceptor_id', or 'draw'
creatorProof: text          // URL/description of proof
acceptorProof: text         // URL/description of proof
votingEndsAt: timestamp     // Deadline for voting
settlementType: varchar     // 'voting' or 'uma' (oracle-based)
```

---

## Notification Examples

**Chat Started:**
```
⚔️ Challenge Started
"Both stakes locked! John's challenge is LIVE. 
Check the chat and submit your proof before the deadline."
```

**Voting Reminder:**
```
⏰ Voting Deadline Alert!
"You have 5 minutes to vote. 
Choose: Creator Won / Draw / Acceptor Won"
```

**Refund Request:**
```
💔 Refund Requested
"John has requested a mutual refund. 
You can accept or decline in the chat."
```

---

## Files to Check

- **Voting:** `/server/routes/api-challenges.ts` (submitVote endpoint)
- **Refund:** `ChallengeChat.tsx` (requestRefundMutation)
- **Chat:** `ChallengeChatPage.tsx`
- **Escrow:** `contracts/src/ChallengeEscrow.sol` (releaseStake)
