<script>
	import { authApiKey } from '../stores/auth';
	const loginUrl = import.meta.env.VITE_LOGIN_URL || '';
	let error;
	let username;
	let password;
	let useremail;

	async function changeData() {}
</script>

<h1>Welcome to the User service</h1>

{#if $authApiKey == null}
	<p>
		You can login <a href="/login"> here</a>.
	</p>
{:else}
	{#await fetch(`${loginUrl}/api/self`, { headers: { Authorization: `Bearer ${$authApiKey}` } })}
		Loading...
	{:then data}
		{#await data.json()}
			Loading
		{:then user}
			<div class="form-group">
				<input
					class="form-control {error == null ? '' : 'is-invalid'}"
					placeholder="Enter email"
					bind:value={useremail}
					required
				/>

				<input
					class="form-control {error == null ? '' : 'is-invalid'}"
					placeholder="Enter username"
					bind:value={username}
					required
				/>

				<input
					class="form-control {error == null ? '' : 'is-invalid'}"
					placeholder="Enter password"
					bind:value={password}
					type="password"
					required
				/>

				<button on:click|preventDefault={changeData} class="btn btn-primary">Change data</button>
			</div>
		{/await}
	{:catch error}
		Error
	{/await}
{/if}
