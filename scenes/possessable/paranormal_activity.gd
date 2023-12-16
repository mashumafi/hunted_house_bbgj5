extends Node

signal contact_made(Possessable) # Called when the ghost can interact with a new object
signal interacted(Possessable) # Called when the ghost interacts with an object

var investigations : Array[Possessable] = []
var recently_interacted : Array[Possessable] = []
