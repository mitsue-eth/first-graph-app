import { BigInt } from "@graphprotocol/graph-ts";
import {
  GameEnded,
  GameStarted,
  OwnershipTransferred,
  PlayerJoined,
} from "../generated/RandomWinnerGame/RandomWinnerGame";
import { Game } from "../generated/schema";

export function handleGameEnded(event: GameEnded): void {
  // Entities can be loaded from the store using a string ID; this ID
  // needs to be unique across all entities of the same type
  let entity = Game.load(event.params.gameId.toString());

  // Entities only exist after they have been saved to the store;
  // `null` checks allow to create entities on demand
  if (!entity) {
    return;
  }

  // Entity fields can be set based on event parameters
  entity.winner = event.params.winner;
  entity.requestId = event.params.requestId;

  // Entities can be written to the store with `.save()`
  entity.save();

  // Note: If a handler doesn't require existing field values, it is faster
  // _not_ to load the entity from the store. Instead, create it fresh with
  // `new Entity(...)`, set the fields that should be updated and save the
  // entity back to the store. Fields that were not set or unset remain
  // unchanged, allowing for partial updates to be applied.

  // It is also possible to access smart contracts from mappings. For
  // example, the contract that has emitted the event can be connected to
  // with:
  //
  // let contract = Contract.bind(event.address)
  //
  // The following functions can then be called on this contract to access
  // state variables and other data:
  //
  // - contract.fee(...)
  // - contract.gameId(...)
  // - contract.gameStarted(...)
  // - contract.keyHash(...)
  // - contract.owner(...)
  // - contract.players(...)
}

export function handleGameStarted(event: GameStarted): void {
  let entity = Game.load(event.params.gameId.toString());
  if (!entity) {
    entity = new Game(event.params.gameId.toString());
    entity.players = [];
  }
  entity.maxPlayers = event.params.maxPlayers;
  entity.entryFee = event.params.entryFee;
  entity.save();
}

export function handleOwnershipTransferred(event: OwnershipTransferred): void {}

export function handlePlayerJoined(event: PlayerJoined): void {
  let entity = Game.load(event.params.gameId.toString());
  if (!entity) {
    return;
  }
  let newPlayers = entity.players;
  newPlayers.push(event.params.player);
  entity.players = newPlayers;
  entity.save();
}
