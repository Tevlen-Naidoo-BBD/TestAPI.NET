namespace PetStoreAPI.Models
{
    public class User
    {
        public int UserId { get; set; }
        public string UserName { get; set; } = default!;
        public string UserEmail { get; set; } = default!;
        public DateTime? DeactivatedAt { get; set; }
    }
} 