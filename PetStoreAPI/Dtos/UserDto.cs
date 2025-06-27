namespace PetStoreAPI.Dtos
{
    public class UserDto
    {
        public int UserId { get; set; }
        public string UserName { get; set; } = default!;
        public string UserEmail { get; set; } = default!;
    }
} 